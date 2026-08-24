import Foundation

/// 6-axis Madgwick AHRS update (gyroscope + accelerometer, no magnetometer).
///
/// This intentionally lives in the platform-independent core so tracking can be
/// tuned and regression-tested without the glasses connected.
public struct MadgwickIMUFilter: Sendable {
    public var beta: Double
    public private(set) var orientation: Quaternion

    public init(beta: Double = 0.08, orientation: Quaternion = .identity) {
        self.beta = beta
        self.orientation = orientation.normalized()
    }

    public mutating func reset(to orientation: Quaternion = .identity) {
        self.orientation = orientation.normalized()
    }

    @discardableResult
    public mutating func update(gyro: Vector3, accelerometer: Vector3, deltaTime dt: Double) -> Quaternion {
        guard dt > 0, dt.isFinite else { return orientation }

        var q1 = orientation.w
        var q2 = orientation.x
        var q3 = orientation.y
        var q4 = orientation.z

        var qDot1 = 0.5 * (-q2 * gyro.x - q3 * gyro.y - q4 * gyro.z)
        var qDot2 = 0.5 * ( q1 * gyro.x + q3 * gyro.z - q4 * gyro.y)
        var qDot3 = 0.5 * ( q1 * gyro.y - q2 * gyro.z + q4 * gyro.x)
        var qDot4 = 0.5 * ( q1 * gyro.z + q2 * gyro.y - q3 * gyro.x)

        if let a = accelerometer.normalized() {
            let ax = a.x
            let ay = a.y
            let az = a.z

            let twoQ1 = 2 * q1
            let twoQ2 = 2 * q2
            let twoQ3 = 2 * q3
            let twoQ4 = 2 * q4
            let fourQ1 = 4 * q1
            let fourQ2 = 4 * q2
            let fourQ3 = 4 * q3
            let eightQ2 = 8 * q2
            let eightQ3 = 8 * q3
            let q1q1 = q1 * q1
            let q2q2 = q2 * q2
            let q3q3 = q3 * q3
            let q4q4 = q4 * q4

            var s1 = fourQ1 * q3q3 + twoQ3 * ax + fourQ1 * q2q2 - twoQ2 * ay
            var s2 = fourQ2 * q4q4 - twoQ4 * ax + 4 * q1q1 * q2 - twoQ1 * ay - fourQ2
                + eightQ2 * q2q2 + eightQ2 * q3q3 + fourQ2 * az
            var s3 = 4 * q1q1 * q3 + twoQ1 * ax + fourQ3 * q4q4 - twoQ4 * ay - fourQ3
                + eightQ3 * q2q2 + eightQ3 * q3q3 + fourQ3 * az
            var s4 = 4 * q2q2 * q4 - twoQ2 * ax + 4 * q3q3 * q4 - twoQ3 * ay

            let stepNorm = sqrt(s1 * s1 + s2 * s2 + s3 * s3 + s4 * s4)
            if stepNorm > 1e-12 {
                s1 /= stepNorm
                s2 /= stepNorm
                s3 /= stepNorm
                s4 /= stepNorm
                qDot1 -= beta * s1
                qDot2 -= beta * s2
                qDot3 -= beta * s3
                qDot4 -= beta * s4
            }
        }

        q1 += qDot1 * dt
        q2 += qDot2 * dt
        q3 += qDot3 * dt
        q4 += qDot4 * dt

        orientation = Quaternion(w: q1, x: q2, y: q3, z: q4).normalized()
        return orientation
    }
}
