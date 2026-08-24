#if os(macOS)
import Foundation
import Combine
import AERCore

@MainActor
final class AERAppModel: ObservableObject {
    enum SpatialMode: String, CaseIterable, Identifiable {
        case off = "Off"
        case follow = "Follow"
        case anchor = "Anchor"

        var id: String { rawValue }
    }

    @Published var mode: SpatialMode = .off
    @Published var screenCaptureAuthorised = ScreenCaptureCoordinator.isAuthorised
    @Published var virtualCanvas = VirtualDisplayConfiguration.default
    @Published var profile = SpatialProfile.air1Desk
    @Published var statusMessage = "Waiting for XREAL Air"

    @Published var syntheticPoseEnabled = false
    @Published var syntheticOrientation = Orientation.zero
    @Published var syntheticViewportOrigin = PixelPoint(x: 960, y: 540)

    let virtualDisplay = VirtualDisplayCoordinator()
    let renderer = MetalViewportRenderer()
    let hardwareMonitor = XREALAirHardwareMonitor()

    private let syntheticHeadPose = SyntheticHeadPoseSource()
    private var syntheticViewport = SpatialViewportController(profile: .air1Desk)
    private var syntheticKeyboard: SyntheticKeyboardDriver?

    init() {
        let keyboard = SyntheticKeyboardDriver()
        keyboard.onNudge = { [weak self] yaw, pitch, roll in
            self?.nudgeSyntheticPose(yawDegrees: yaw, pitchDegrees: pitch, rollDegrees: roll)
        }
        keyboard.onRecenter = { [weak self] in self?.recenter() }
        syntheticKeyboard = keyboard

        hardwareMonitor.onDevicesChanged = { [weak self] devices in
            guard let self else { return }
            Task { @MainActor in
                if devices.isEmpty {
                    if !self.syntheticPoseEnabled {
                        self.statusMessage = "Waiting for XREAL Air"
                    }
                } else {
                    self.statusMessage = "XREAL Air HID detected (\(devices.count) interface(s))"
                }
            }
        }
        hardwareMonitor.startPolling()
    }

    var menuBarSymbol: String {
        switch mode {
        case .off: "eyeglasses"
        case .follow: "move.3d"
        case .anchor: "view.3d"
        }
    }

    var syntheticPoseDescription: String {
        String(
            format: "yaw %+.1f°  pitch %+.1f°  roll %+.1f°",
            syntheticOrientation.yawDegrees,
            syntheticOrientation.pitchDegrees,
            syntheticOrientation.rollDegrees
        )
    }

    var syntheticViewportDescription: String {
        String(format: "crop %.0f, %.0f", syntheticViewportOrigin.x, syntheticViewportOrigin.y)
    }

    func requestScreenCapturePermission() {
        screenCaptureAuthorised = ScreenCaptureCoordinator.isAuthorised
        if !screenCaptureAuthorised {
            screenCaptureAuthorised = ScreenCaptureCoordinator.requestAuthorisation()
        }
    }

    func recenter() {
        if syntheticPoseEnabled {
            syntheticViewport.recenter(at: syntheticOrientation)
            syntheticViewportOrigin = syntheticViewport.viewportOrigin(for: syntheticOrientation)
            statusMessage = "Synthetic pose recentered"
        } else {
            statusMessage = "Recenter requested"
        }
    }

    func setMode(_ newMode: SpatialMode) {
        mode = newMode
        switch newMode {
        case .off:
            statusMessage = "Spatial output off"
        case .follow:
            statusMessage = syntheticPoseEnabled
                ? "Follow mode — synthetic head input"
                : "Follow mode staged — hardware pending"
        case .anchor:
            statusMessage = syntheticPoseEnabled
                ? "Anchor mode — synthetic head input"
                : "Anchor mode staged — hardware pending"
        }
    }

    func setSyntheticPoseEnabled(_ enabled: Bool) {
        guard enabled != syntheticPoseEnabled else { return }
        syntheticPoseEnabled = enabled

        if enabled {
            syntheticViewport = SpatialViewportController(profile: profile)
            syntheticViewport.recenter(at: syntheticHeadPose.orientation)
            do {
                try syntheticHeadPose.start { [weak self] sample in
                    guard let self else { return }
                    Task { @MainActor in self.consumeSyntheticPose(sample) }
                }
                syntheticKeyboard?.start()
                statusMessage = "Synthetic head input active"
            } catch {
                syntheticPoseEnabled = false
                statusMessage = "Synthetic input error: \(error.localizedDescription)"
            }
        } else {
            syntheticKeyboard?.stop()
            syntheticHeadPose.stop()
            statusMessage = hardwareMonitor.devices.isEmpty
                ? "Waiting for XREAL Air"
                : "XREAL Air HID detected"
        }
    }

    func setSyntheticPoseDegrees(yaw: Double? = nil, pitch: Double? = nil, roll: Double? = nil) {
        syntheticHeadPose.setDegrees(yaw: yaw, pitch: pitch, roll: roll)
    }

    func nudgeSyntheticPose(yawDegrees: Double = 0, pitchDegrees: Double = 0, rollDegrees: Double = 0) {
        syntheticHeadPose.nudgeDegrees(yaw: yawDegrees, pitch: pitchDegrees, roll: rollDegrees)
    }

    func resetSyntheticPose() {
        syntheticHeadPose.reset()
        recenter()
    }

    private func consumeSyntheticPose(_ sample: HeadPoseSample) {
        syntheticOrientation = sample.orientation
        syntheticViewportOrigin = syntheticViewport.viewportOrigin(for: sample.orientation)
    }
}
#endif
