#if os(macOS)
import SwiftUI

@main
struct AERMacApp: App {
    @StateObject private var model = AERAppModel()

    var body: some Scene {
        MenuBarExtra("AER", systemImage: model.menuBarSymbol) {
            AERMenuView(model: model)
        }
        .menuBarExtraStyle(.window)
    }
}
#else
import Foundation

@main
enum AERMacUnsupportedHost {
    static func main() {
        print("AERMac is a macOS-only menu-bar application.")
    }
}
#endif
