import Foundation

public struct HeadPoseSample: Equatable, Sendable {
    public var timestamp: Double
    public var orientation: Orientation
    public var angularVelocity: Vector3?

    public init(timestamp: Double, orientation: Orientation, angularVelocity: Vector3? = nil) {
        self.timestamp = timestamp
        self.orientation = orientation
        self.angularVelocity = angularVelocity
    }
}

public protocol HeadPoseSource: AnyObject {
    var displayName: String { get }
    var isRunning: Bool { get }
    func start(_ onPose: @escaping (HeadPoseSample) -> Void) throws
    func stop()
}

public struct TranslationSample: Equatable, Sendable {
    public var timestamp: Double
    /// Head/device translation in metres in the source's calibrated coordinate space.
    public var position: Vector3

    public init(timestamp: Double, position: Vector3) {
        self.timestamp = timestamp
        self.position = position
    }
}

public protocol TranslationSource: AnyObject {
    var displayName: String { get }
    var isRunning: Bool { get }
    func start(_ onTranslation: @escaping (TranslationSample) -> Void) throws
    func stop()
}

public enum Handedness: String, Codable, CaseIterable, Sendable {
    case left
    case right
    case unknown
}

public enum HandJoint: String, Codable, CaseIterable, Sendable {
    case wrist
    case thumbTip
    case indexTip
    case middleTip
    case ringTip
    case littleTip
}

public struct HandPoseSample: Equatable, Sendable {
    public var timestamp: Double
    public var handedness: Handedness
    /// Joint positions in metres in the source's coordinate space.
    public var joints: [HandJoint: Vector3]
    public var confidence: Double?

    public init(
        timestamp: Double,
        handedness: Handedness,
        joints: [HandJoint: Vector3],
        confidence: Double? = nil
    ) {
        self.timestamp = timestamp
        self.handedness = handedness
        self.joints = joints
        self.confidence = confidence
    }
}

public protocol HandPoseSource: AnyObject {
    var displayName: String { get }
    var isRunning: Bool { get }
    func start(_ onHands: @escaping ([HandPoseSample]) -> Void) throws
    func stop()
}

public enum SpatialGestureKind: String, Codable, CaseIterable, Sendable {
    case pinch
    case grab
    case point
    case scroll
    case openPalm
    case twoHandScale
    case custom
}

public enum SpatialGesturePhase: String, Codable, Sendable {
    case began
    case changed
    case ended
    case cancelled
}

public struct SpatialGestureEvent: Equatable, Sendable {
    public var timestamp: Double
    public var kind: SpatialGestureKind
    public var phase: SpatialGesturePhase
    public var position: Vector3?
    public var scalarValue: Double?

    public init(
        timestamp: Double,
        kind: SpatialGestureKind,
        phase: SpatialGesturePhase,
        position: Vector3? = nil,
        scalarValue: Double? = nil
    ) {
        self.timestamp = timestamp
        self.kind = kind
        self.phase = phase
        self.position = position
        self.scalarValue = scalarValue
    }
}

public protocol GestureSource: AnyObject {
    var displayName: String { get }
    var isRunning: Bool { get }
    func start(_ onGesture: @escaping (SpatialGestureEvent) -> Void) throws
    func stop()
}

public enum SpatialInputSourceError: Error, Equatable {
    case alreadyRunning
    case unavailable(String)
}
