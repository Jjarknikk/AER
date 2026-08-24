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

    let virtualDisplay = VirtualDisplayCoordinator()
    let renderer = MetalViewportRenderer()

    var menuBarSymbol: String {
        switch mode {
        case .off: "eyeglasses"
        case .follow: "move.3d"
        case .anchor: "view.3d"
        }
    }

    func requestScreenCapturePermission() {
        screenCaptureAuthorised = ScreenCaptureCoordinator.requestAuthorisation()
    }

    func recenter() {
        statusMessage = "Recenter requested"
    }

    func setMode(_ newMode: SpatialMode) {
        mode = newMode
        switch newMode {
        case .off:
            statusMessage = "Spatial output off"
        case .follow:
            statusMessage = "Follow mode staged — hardware pending"
        case .anchor:
            statusMessage = "Anchor mode staged — hardware pending"
        }
    }
}
#endif
