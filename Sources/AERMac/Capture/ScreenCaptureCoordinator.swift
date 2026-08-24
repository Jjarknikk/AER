#if os(macOS)
import CoreGraphics
import ScreenCaptureKit

/// Thin ScreenCaptureKit boundary. Capture session wiring is intentionally kept
/// out of tracking code so we can benchmark capture and pose latency separately.
enum ScreenCaptureCoordinator {
    static var isAuthorised: Bool {
        CGPreflightScreenCaptureAccess()
    }

    @discardableResult
    static func requestAuthorisation() -> Bool {
        CGRequestScreenCaptureAccess()
    }

    static func availableDisplays() async throws -> [SCDisplay] {
        let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
        return content.displays
    }
}
#endif
