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

    func testXREALAir1Identifiers() {
        XCTAssertEqual(XREALDeviceDescriptor.air1.vendorID, 0x3318)
        XCTAssertEqual(XREALDeviceDescriptor.air1.productID, 0x0424)
        XCTAssertEqual(XREALDeviceDescriptor.air1.imuInterface, 3)
        XCTAssertEqual(XREALDeviceDescriptor.air1.mcuInterface, 4)
    }
}
