import Foundation

public struct Quaternion: Equatable, Sendable {
    public var w: Double
    public var x: Double
    public var y: Double
    public var z: Double

    public init(w: Double, x: Double, y: Double, z: Double) {
        self.w = w
        self.x = x
        self.y = y
        self.z = z
    }

    public static let identity = Quaternion(w: 1, x: 0, y: 0, z: 0)

    public var magnitudeSquared: Double { w * w + x * x + y * y + z * z }
    public var magnitude: Double { sqrt(magnitudeSquared) }

    public func normalized(epsilon: Double = 1e-12) -> Quaternion {
        let m = magnitude
        guard m > epsilon else { return .identity }
        return Quaternion(w: w / m, x: x / m, y: y / m, z: z / m)
    }

    public var conjugate: Quaternion {
        Quaternion(w: w, x: -x, y: -y, z: -z)
    }

    public static func *(lhs: Quaternion, rhs: Quaternion) -> Quaternion {
        Quaternion(
            w: lhs.w * rhs.w - lhs.x * rhs.x - lhs.y * rhs.y - lhs.z * rhs.z,
            x: lhs.w * rhs.x + lhs.x * rhs.w + lhs.y * rhs.z - lhs.z * rhs.y,
            y: lhs.w * rhs.y - lhs.x * rhs.z + lhs.y * rhs.w + lhs.z * rhs.x,
            z: lhs.w * rhs.z + lhs.x * rhs.y - lhs.y * rhs.x + lhs.z * rhs.w
        )
    }

    public static func fromAxisAngle(axis: Vector3, radians: Double) -> Quaternion {
        guard let unit = axis.normalized() else { return .identity }
        let half = radians * 0.5
        let s = sin(half)
        return Quaternion(w: cos(half), x: unit.x * s, y: unit.y * s, z: unit.z * s)
    }

    public func rotated(_ vector: Vector3) -> Vector3 {
        let p = Quaternion(w: 0, x: vector.x, y: vector.y, z: vector.z)
        let r = self * p * conjugate
        return Vector3(x: r.x, y: r.y, z: r.z)
    }
}
