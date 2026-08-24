# AERMac

The live SwiftPM macOS target now lives under [`Sources/AERMac`](../../Sources/AERMac).

Current pre-hardware scaffold includes:

1. menu-bar SwiftUI application shell
2. ScreenCaptureKit permission and display-discovery boundary
3. Metal renderer initialization and viewport-crop shader
4. virtual-display lifecycle boundary for the forthcoming `CGVirtualDisplay` backend
5. Anchor / Follow / Recenter controls staged in the app model

The platform-independent tracking engine remains in `AERCore` so pose filtering, prediction and viewport behaviour can be tested without physical glasses.

`CGVirtualDisplay` is private API, so AER is expected to be distributed outside the Mac App Store.
