import Foundation

public struct SpatialProfile: Equatable, Sendable {
    public var name: String
    public var horizontalFOVDegrees: Double
    public var verticalFOVDegrees: Double
    public var yawGain: Double
    public var pitchGain: Double
    public var smoothing: Double
    public var predictionMilliseconds: Double

    public init(
        name: String,
        horizontalFOVDegrees: Double = 46,
        verticalFOVDegrees: Double = 27,
        yawGain: Double = 1,
        pitchGain: Double = 1,
        smoothing: Double = 0.18,
        predictionMilliseconds: Double = 8
    ) {
        self.name = name
        self.horizontalFOVDegrees = horizontalFOVDegrees
        self.verticalFOVDegrees = verticalFOVDegrees
        self.yawGain = yawGain
        self.pitchGain = pitchGain
        self.smoothing = smoothing
        self.predictionMilliseconds = predictionMilliseconds
    }

    public static let air1Desk = SpatialProfile(name: "Air 1 Desk")
}
