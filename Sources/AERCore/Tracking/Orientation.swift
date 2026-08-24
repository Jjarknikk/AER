import Foundation

public struct Orientation: Equatable, Sendable {
    public var yaw: Double
    public var pitch: Double
    public var roll: Double

    public init(yaw: Double, pitch: Double, roll: Double) {
        self.yaw = yaw
        self.pitch = pitch
        self.roll = roll
    }

    public static let zero = Orientation(yaw: 0, pitch: 0, roll: 0)

    public var yawDegrees: Double { yaw * 180 / .pi }
    public var pitchDegrees: Double { pitch * 180 / .pi }
    public var rollDegrees: Double { roll * 180 / .pi }

    public init(quaternion q: Quaternion) {
        let q = q.normalized()

        let sinyCosp = 2 * (q.w * q.z + q.x * q.y)
        let cosyCosp = 1 - 2 * (q.y * q.y + q.z * q.z)
        yaw = atan2(sinyCosp, cosyCosp)

        let sinp = 2 * (q.w * q.y - q.z * q.x)
        pitch = abs(sinp) >= 1 ? copysign(.pi / 2, sinp) : asin(sinp)

        let sinrCosp = 2 * (q.w * q.x + q.y * q.z)
        let cosrCosp = 1 - 2 * (q.x * q.x + q.y * q.y)
        roll = atan2(sinrCosp, cosrCosp)
    }
}
