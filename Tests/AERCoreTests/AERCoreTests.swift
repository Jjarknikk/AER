import XCTest
@testable import AERCore

final class AERCoreTests: XCTestCase {
    func testQuaternionAxisAngleProducesExpectedYaw() {
        let q = Quaternion.fromAxisAngle(axis: Vector3(x: 0, y: 0, z: 1), radians: .pi / 2)
        let o = Orientation(quaternion: q)
        XCTAssertEqual(o.yawDegrees, 90, accuracy: 0.001)
        XCTAssertEqual(o.pitchDegrees, 0, accuracy: 0.001)
        XCTAssertEqual(o.rollDegrees, 0, accuracy: 0.001)
    }

    func testStationaryMadgwickStaysNearIdentity() {
        var filter = MadgwickIMUFilter(beta: 0.08)
        for sample in SyntheticIMU.stationary(duration: 4, sampleRate: 120) {
            _ = filter.update(gyro: sample.gyro, accelerometer: sample.accelerometer, deltaTime: 1.0 / 120.0)
        }
        let orientation = Orientation(quaternion: filter.orientation)
        XCTAssertEqual(orientation.yawDegrees, 0, accuracy: 0.05)
        XCTAssertEqual(orientation.pitchDegrees, 0, accuracy: 0.05)
        XCTAssertEqual(orientation.rollDegrees, 0, accuracy: 0.05)
    }

    func testViewportRecentersToCanvasMiddle() {
        var controller = SpatialViewportController(
            canvas: PixelSize(width: 3840, height: 2160),
            viewport: PixelSize(width: 1920, height: 1080),
            profile: SpatialProfile(name: "test", smoothing: 0)
        )
        let pose = Orientation(yaw: 0.7, pitch: -0.2, roll: 0.1)
        controller.recenter(at: pose)
        let origin = controller.viewportOrigin(for: pose)
        XCTAssertEqual(origin.x, 960, accuracy: 0.001)
        XCTAssertEqual(origin.y, 540, accuracy: 0.001)
    }

    func testYawMovesViewportHorizontally() {
        var controller = SpatialViewportController(
            profile: SpatialProfile(name: "test", smoothing: 0)
        )
        controller.recenter(at: .zero)
        let center = controller.viewportOrigin(for: .zero)
        let moved = controller.viewportOrigin(for: Orientation(yaw: 10 * .pi / 180, pitch: 0, roll: 0))
        XCTAssertGreaterThan(moved.x, center.x)
        XCTAssertEqual(moved.y, center.y, accuracy: 0.001)
    }

    func testTrackingEngineRecentersOnFirstSample() {
        var engine = SpatialTrackingEngine(
            viewport: SpatialViewportController(profile: SpatialProfile(name: "test", smoothing: 0, predictionMilliseconds: 0))
        )
        let sample = IMUSample(
            timestamp: 0,
            gyro: Vector3(x: 0, y: 0, z: 0.4),
            accelerometer: Vector3(x: 0, y: 0, z: 1)
        )
        let first = engine.process(sample)
        XCTAssertEqual(first.viewportOrigin.x, 960, accuracy: 0.001)
        XCTAssertEqual(first.viewportOrigin.y, 540, accuracy: 0.001)
    }

    func testTrackingEnginePredictionLeadsYawDuringMotion() {
        var engine = SpatialTrackingEngine(
            viewport: SpatialViewportController(profile: SpatialProfile(name: "test", smoothing: 0, predictionMilliseconds: 10))
        )
        _ = engine.process(IMUSample(timestamp: 0, gyro: .zero, accelerometer: Vector3(x: 0, y: 0, z: 1)))
        let moving = engine.process(IMUSample(
            timestamp: 1.0 / 120.0,
            gyro: Vector3(x: 0, y: 0, z: 1.0),
            accelerometer: Vector3(x: 0, y: 0, z: 1)
        ))
        XCTAssertGreaterThan(moving.predictedOrientation.yaw, moving.orientation.yaw)
    }

    func testAERIMURecordingV2RoundTrips() throws {
        let source = SyntheticIMU.yawSweep(duration: 0.2, sampleRate: 20)
        let header = AERIMUHeader(
            createdAtUTC: "2026-08-24T20:00:00Z",
            device: .air1,
            units: .normalizedSI,
            timestampSource: .synthetic,
            calibrationTransform: .identity,
            notes: "fixture"
        )
        let recording = AERIMURecording(
            source: "synthetic",
            nominalSampleRateHz: 20,
            header: header,
            samples: source
        )
        let decoded = try AERIMURecording.decode(recording.encoded())
        XCTAssertEqual(decoded, recording)
        XCTAssertEqual(decoded.formatVersion, 2)
        XCTAssertEqual(decoded.header?.device?.productID, 0x0424)
        XCTAssertTrue(decoded.header?.calibrationTransform.isValid == true)
    }

    func testAERIMUStillDecodesV1WithoutHeader() throws {
        let legacy = #"{"formatVersion":1,"source":"legacy","nominalSampleRateHz":60,"samples":[]}"#.data(using: .utf8)!
        let decoded = try AERIMURecording.decode(legacy)
        XCTAssertEqual(decoded.formatVersion, 1)
        XCTAssertEqual(decoded.source, "legacy")
        XCTAssertNil(decoded.header)
    }

    func testSpatialInputContractsCarryPoseAndHands() {
        let head = HeadPoseSample(
            timestamp: 1,
            orientation: Orientation(yaw: 0.1, pitch: 0.2, roll: 0.3),
            angularVelocity: Vector3(x: 1, y: 2, z: 3)
        )
        XCTAssertEqual(head.orientation.pitch, 0.2, accuracy: 0.0001)

        let hand = HandPoseSample(
            timestamp: 1,
            handedness: .right,
            joints: [.indexTip: Vector3(x: 0.1, y: 0.2, z: 0.3)],
            confidence: 0.9
        )
        XCTAssertEqual(hand.joints[.indexTip]?.z ?? .nan, 0.3, accuracy: 0.0001)
    }

    func testXREALAir1Identifiers() {
        XCTAssertEqual(XREALDeviceDescriptor.air1.vendorID, 0x3318)
        XCTAssertEqual(XREALDeviceDescriptor.air1.productID, 0x0424)
        XCTAssertEqual(XREALDeviceDescriptor.air1.imuInterface, 3)
        XCTAssertEqual(XREALDeviceDescriptor.air1.mcuInterface, 4)
    }
}
