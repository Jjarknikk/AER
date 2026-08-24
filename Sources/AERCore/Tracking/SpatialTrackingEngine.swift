import Foundation

public struct TrackingFrame: Equatable, Sendable {
    public var timestamp: Double
    public var orientation: Orientation
    public var predictedOrientation: Orientation
    public var viewportOrigin: PixelPoint

    public init(timestamp: Double, orientation: Orientation, predictedOrientation: Orientation, viewportOrigin: PixelPoint) {
        self.timestamp = timestamp
        self.orientation = orientation
        self.predictedOrientation = predictedOrientation
        self.viewportOrigin = viewportOrigin
    }
}

/// End-to-end platform-neutral tracking pipeline.
///
/// Hardware code only has to normalize an XREAL packet into `IMUSample`; this engine
/// handles timing, sensor fusion, short-horizon prediction, recentering and viewport mapping.
public struct SpatialTrackingEngine: Sendable {
    public private(set) var filter: MadgwickIMUFilter
    public private(set) var viewport: SpatialViewportController
    public private(set) var lastFrame: TrackingFrame?

    private var previousTimestamp: Double?
    private var recenterOnNextFrame = true

    public init(
        filter: MadgwickIMUFilter = MadgwickIMUFilter(),
        viewport: SpatialViewportController = SpatialViewportController()
    ) {
        self.filter = filter
        self.viewport = viewport
    }

    public mutating func requestRecenter() {
        recenterOnNextFrame = true
    }

    public mutating func resetTracking() {
        filter.reset()
        previousTimestamp = nil
        lastFrame = nil
        recenterOnNextFrame = true
    }

    @discardableResult
    public mutating func process(_ sample: IMUSample, defaultDeltaTime: Double = 1.0 / 120.0) -> TrackingFrame {
        let dt: Double
        if let previousTimestamp {
            let measured = sample.timestamp - previousTimestamp
            dt = measured > 0 && measured < 0.25 ? measured : defaultDeltaTime
        } else {
            dt = defaultDeltaTime
        }
        previousTimestamp = sample.timestamp

        let q = filter.update(gyro: sample.gyro, accelerometer: sample.accelerometer, deltaTime: dt)
        let orientation = Orientation(quaternion: q)

        if recenterOnNextFrame {
            viewport.recenter(at: orientation)
            recenterOnNextFrame = false
        }

        let predictionSeconds = max(0, viewport.profile.predictionMilliseconds) / 1000
        let predictedQ = predict(q, angularVelocity: sample.gyro, horizon: predictionSeconds)
        let predictedOrientation = Orientation(quaternion: predictedQ)
        let origin = viewport.viewportOrigin(for: predictedOrientation)

        let frame = TrackingFrame(
            timestamp: sample.timestamp,
            orientation: orientation,
            predictedOrientation: predictedOrientation,
            viewportOrigin: origin
        )
        lastFrame = frame
        return frame
    }

    private func predict(_ q: Quaternion, angularVelocity gyro: Vector3, horizon: Double) -> Quaternion {
        guard horizon > 0 else { return q }
        let speed = gyro.magnitude
        guard speed > 1e-9 else { return q }
        let delta = Quaternion.fromAxisAngle(axis: gyro / speed, radians: speed * horizon)
        return (q * delta).normalized()
    }
}
