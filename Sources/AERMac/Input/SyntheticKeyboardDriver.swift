#if os(macOS)
import AppKit

/// Local keyboard controls for pre-hardware spatial testing. The monitor only
/// acts while an AER window/menu has keyboard focus, so it does not require a
/// global key logger or Accessibility permission.
final class SyntheticKeyboardDriver {
    var onNudge: ((Double, Double, Double) -> Void)?
    var onRecenter: (() -> Void)?
    private var monitor: Any?

    func start() {
        guard monitor == nil else { return }
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self, event.modifierFlags.contains(.option) else { return event }

            let handled: Bool
            switch event.keyCode {
            case 123: // left
                self.onNudge?(-2, 0, 0); handled = true
            case 124: // right
                self.onNudge?(2, 0, 0); handled = true
            case 125: // down
                self.onNudge?(0, -2, 0); handled = true
            case 126: // up
                self.onNudge?(0, 2, 0); handled = true
            default:
                switch event.charactersIgnoringModifiers?.lowercased() {
                case "q": self.onNudge?(0, 0, -2); handled = true
                case "e": self.onNudge?(0, 0, 2); handled = true
                case "0": self.onRecenter?(); handled = true
                default: handled = false
                }
            }
            return handled ? nil : event
        }
    }

    func stop() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
}
#endif
