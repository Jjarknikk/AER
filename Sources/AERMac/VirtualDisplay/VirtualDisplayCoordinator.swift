#if os(macOS)
import Foundation

struct VirtualDisplayConfiguration: Equatable, Sendable {
    var width: Double
    var height: Double
    var refreshRate: Double

    static let `default` = VirtualDisplayConfiguration(width: 3840, height: 2160, refreshRate: 60)
}

/// Lifecycle boundary for the future CGVirtualDisplay adapter.
///
/// CGVirtualDisplay is private API. We deliberately keep it behind this small
/// type so the rest of AER can remain testable and so a future public/fallback
/// backend can be substituted without touching tracking or rendering.
@MainActor
final class VirtualDisplayCoordinator {
    enum State: Equatable {
        case stopped
        case staged(VirtualDisplayConfiguration)
        case running(VirtualDisplayConfiguration)
    }

    private(set) var state: State = .stopped

    func stage(_ configuration: VirtualDisplayConfiguration) {
        state = .staged(configuration)
    }

    func markRunning(_ configuration: VirtualDisplayConfiguration) {
        state = .running(configuration)
    }

    func stop() {
        state = .stopped
    }
}
#endif
