import Foundation

/// Deterministic sample generator used before physical glasses are available and in tests.
public enum SyntheticIMU {
    public static func stationary(duration: Double, sampleRate: Double) -> [IMUSample] {
        samples(duration: duration, sampleRate: sampleRate) { _ in
            (gyro: .zero, acceleration: Vector3(x: 0, y: 0, z: 1))
        }
    }

    /// A smooth left/right yaw sweep. The simulated yaw angle follows a sine wave.
    public static func yawSweep(
        duration: Double,
        sampleRate: Double,
        amplitudeDegrees: Double = 30,
        period: Double = 4
    ) -> [IMUSample] {
        let amplitude = amplitudeDegrees * .pi / 180
        let omega = 2 * Double.pi / period
        return samples(duration: duration, sampleRate: sampleRate) { t in
            let yawRate = amplitude * omega * cos(omega * t)
            return (
                gyro: Vector3(x: 0, y: 0, z: yawRate),
                acceleration: Vector3(x: 0, y: 0, z: 1)
            )
        }
    }

    public static func pitchSweep(
        duration: Double,
        sampleRate: Double,
        amplitudeDegrees: Double = 20,
        period: Double = 4
    ) -> [IMUSample] {
        let amplitude = amplitudeDegrees * .pi / 180
        let omega = 2 * Double.pi / period
        return samples(duration: duration, sampleRate: sampleRate) { t in
            let pitchRate = amplitude * omega * cos(omega * t)
            return (
                gyro: Vector3(x: 0, y: pitchRate, z: 0),
                acceleration: Vector3(x: 0, y: 0, z: 1)
            )
        }
    }

    private static func samples(
        duration: Double,
        sampleRate: Double,
        motion: (Double) -> (gyro: Vector3, acceleration: Vector3)
    ) -> [IMUSample] {
        guard duration > 0, sampleRate > 0 else { return [] }
        let count = Int((duration * sampleRate).rounded(.down)) + 1
        return (0..<count).map { index in
            let t = Double(index) / sampleRate
            let value = motion(t)
            return IMUSample(timestamp: t, gyro: value.gyro, accelerometer: value.acceleration)
        }
    }
}
