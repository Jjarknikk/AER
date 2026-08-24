import Foundation

public struct PixelPoint: Equatable, Sendable {
    public var x: Double
    public var y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

public struct PixelSize: Equatable, Sendable {
    public var width: Double
    public var height: Double

    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
}

/// Maps a head orientation onto a crop origin in a larger virtual desktop canvas.
/// Rendering is deliberately separate: this type is deterministic and testable.
public struct SpatialViewportController: Sendable {
    public var canvas: PixelSize
    public var viewport: PixelSize
    public var profile: SpatialProfile

    private var reference = Orientation.zero
    private var smoothedOrigin: PixelPoint?

    public init(
        canvas: PixelSize = PixelSize(width: 3840, height: 2160),
        viewport: PixelSize = PixelSize(width: 1920, height: 1080),
        profile: SpatialProfile = .air1Desk
    ) {
        self.canvas = canvas
        self.viewport = viewport
        self.profile = profile
    }

    public mutating func recenter(at orientation: Orientation) {
        reference = orientation
        smoothedOrigin = nil
    }

    public mutating func viewportOrigin(for orientation: Orientation) -> PixelPoint {
        let maxX = max(0, canvas.width - viewport.width)
        let maxY = max(0, canvas.height - viewport.height)
        let center = PixelPoint(x: maxX * 0.5, y: maxY * 0.5)

        let hFOV = max(profile.horizontalFOVDegrees, 1) * .pi / 180
        let vFOV = max(profile.verticalFOVDegrees, 1) * .pi / 180
        let pxPerRadX = viewport.width / hFOV
        let pxPerRadY = viewport.height / vFOV

        let yawDelta = wrappedAngle(orientation.yaw - reference.yaw)
        let pitchDelta = wrappedAngle(orientation.pitch - reference.pitch)

        let target = PixelPoint(
            x: clamp(center.x + yawDelta * pxPerRadX * profile.yawGain, lower: 0, upper: maxX),
            y: clamp(center.y - pitchDelta * pxPerRadY * profile.pitchGain, lower: 0, upper: maxY)
        )

        let smoothing = clamp(profile.smoothing, lower: 0, upper: 0.98)
        guard let previous = smoothedOrigin else {
            smoothedOrigin = target
            return target
        }

        let alpha = 1 - smoothing
        let output = PixelPoint(
            x: previous.x + (target.x - previous.x) * alpha,
            y: previous.y + (target.y - previous.y) * alpha
        )
        smoothedOrigin = output
        return output
    }

    private func wrappedAngle(_ angle: Double) -> Double {
        var result = angle
        while result > .pi { result -= 2 * .pi }
        while result < -.pi { result += 2 * .pi }
        return result
    }

    private func clamp(_ value: Double, lower: Double, upper: Double) -> Double {
        min(max(value, lower), upper)
    }
}
