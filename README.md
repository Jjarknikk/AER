# AER

**Experimental spatial desktop for XREAL Air on macOS.**

AER's first target is the original **Nreal/XREAL Air (NR-7100RGL)** connected directly to a Mac over USB-C. The aim is to provide a lightweight, hackable alternative to Beam/Nebula: anchored displays, smooth follow, custom workspaces and image/tracking controls, while keeping firmware modification optional and isolated.

> Status: **Phase 0 / hardware-independent core**. The glasses have not been connected to this project yet.

## What already works

The repository starts with a testable platform-neutral core:

- quaternion/vector math
- 6-axis Madgwick orientation filter
- deterministic synthetic IMU streams
- orientation → virtual viewport mapping
- spatial tuning profile model
- verified Air 1/Air 2 USB identifiers
- CLI simulation for development before hardware arrives
- unit tests

Run it now:

```bash
swift test
swift run aer-sim
```

The simulator prints a synthetic yaw sweep and the corresponding viewport position in a 3840×2160 virtual canvas.

## Target macOS stack

```text
XREAL Air IMU ── USB HID ──> AERHardwareMac ──> AERCore tracking
                                                     │
CGVirtualDisplay ──> ScreenCaptureKit ───────────────┤
                                                     v
                                                  Metal
                                                     │
                                                     v
                                           XREAL Air display
```

The macOS app will be a menu-bar utility with:

- **Anchor** — world-ish fixed 3DoF display
- **Follow** — damped head-following display
- **Recenter** global shortcut
- display size/distance presets
- ultrawide and workspace presets
- brightness / refresh controls where hardware permits
- smoothing and motion-prediction tuning
- software gamma, RGB, contrast and sharpening controls

## Hardware target

Original Air identifiers are recorded in `XREALDeviceDescriptor`:

```text
Vendor ID      0x3318
Product ID     0x0424
IMU interface  3
MCU interface  4
```

These values are taken from the MIT-licensed `xrealair-sdk-macos` community driver and will be verified against the physical pair on arrival.

## Principles

1. **Stock firmware first.** No flashing until the hardware is fully tested.
2. **Record before tuning.** Real IMU captures become regression fixtures.
3. **Separate risky operations.** Firmware experiments never belong in the normal spatial app.
4. **Mac first.** Get excellent 3DoF on macOS before attempting Android.
5. **Measure latency.** Spatial comfort is a systems problem, not just a smoothing slider.

## Project docs

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
- [`docs/ROADMAP.md`](docs/ROADMAP.md)
- [`docs/HARDWARE_ARRIVAL.md`](docs/HARDWARE_ARRIVAL.md)
- [`docs/PROTOCOL_NOTES.md`](docs/PROTOCOL_NOTES.md)
- [`docs/REFERENCES.md`](docs/REFERENCES.md)

## Name

*AER* is Latin (via Greek) for **air**. Short enough for a menu-bar utility and appropriately literal for the hardware.

## License

MIT. External code is not currently vendored; any future vendored MIT source must retain its original notices.
