#if os(macOS)
import Foundation
import AERCore

/// Manual pose source used to develop the spatial compositor before the glasses
/// arrive. Sliders/mouse input and local keyboard nudges feed the same
/// `HeadPoseSource` abstraction that real Air tracking will eventually use.
final class SyntheticHeadPoseSource: HeadPoseSource {
    let displayName = "Synthetic head pose"
    private(set) var isRunning = false
    private var callback: ((HeadPoseSample) -> Void)?
    private(set) var orientation = Orientation.zero

    func start(_ onPose: @escaping (HeadPoseSample) -> Void) throws {
        guard !isRunning else { throw SpatialInputSourceError.alreadyRunning }
        callback = onPose
        isRunning = true
        publish()
    }

    func stop() {
        isRunning = false
        callback = nil
    }

    func setDegrees(yaw: Double? = nil, pitch: Double? = nil, roll: Double? = nil) {
        if let yaw { orientation.yaw = yaw * .pi / 180 }
        if let pitch { orientation.pitch = pitch * .pi / 180 }
        if let roll { orientation.roll = roll * .pi / 180 }
        publish()
    }

    func nudgeDegrees(yaw: Double = 0, pitch: Double = 0, roll: Double = 0) {
        orientation.yaw += yaw * .pi / 180
        orientation.pitch += pitch * .pi / 180
        orientation.roll += roll * .pi / 180
        publish()
    }

    func reset() {
        orientation = .zero
        publish()
    }

    private func publish() {
        guard isRunning else { return }
        callback?(HeadPoseSample(
            timestamp: ProcessInfo.processInfo.systemUptime,
            orientation: orientation
        ))
    }
}
#endif
