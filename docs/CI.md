# Continuous integration

AER validates two different surfaces on every push and pull request:

- **Core tests (Linux):** builds/tests the platform-independent tracking core and runs the deterministic simulator.
- **macOS app + Metal:** runs the same core tests on macOS, builds the real `AERMac` target (including SwiftUI, ScreenCaptureKit, IOKit and Metal imports), then compiles `AERViewport.metal` with Apple's Metal compiler.

The Linux job is useful for fast deterministic logic checks, but it is **not** evidence that Apple-only code compiles. Treat the macOS job as the gate for changes under `Sources/AERMac/`.
