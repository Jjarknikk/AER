import Foundation

public struct IMUSample: Equatable, Sendable {
    /// Monotonic timestamp in seconds. Only deltas are significant.
    public var timestamp: Double
    /// Angular velocity in radians per second.
    public var gyro: Vector3
    /// Linear acceleration including gravity, in arbitrary consistent units.
    public var accelerometer: Vector3

    public init(timestamp: Double, gyro: Vector3, accelerometer: Vector3) {
        self.timestamp = timestamp
        self.gyro = gyro
        self.accelerometer = accelerometer
    }
}
