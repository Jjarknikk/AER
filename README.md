# AER

**Experimental spatial desktop for XREAL Air on macOS.**

AER's first target is the original **Nreal/XREAL Air (NR-7100RGL)** connected directly to a Mac over USB-C. The aim is a lightweight, hackable alternative to Beam/Nebula: anchored displays, smooth follow, custom workspaces and image/tracking controls, while keeping firmware modification optional and isolated.

> Status: **Phase 0.5 / pre-hardware integration**. The physical glasses have not been connected to AER yet.

## What already exists

- quaternion/vector math
- 6-axis Madgwick orientation filter
- deterministic synthetic IMU streams
- orientation → virtual viewport mapping
- pose prediction and spatial tuning profiles
- Air 1/Air 2 USB identifiers
- `.aerimu` v2 recording metadata
- generic head/translation/hand/gesture input contracts
- synthetic mouse/slider + local-keyboard head-pose controls for the Mac app
- read-only Air 1 HID discovery/attach-detach monitor
- raw HID packet logging sink
- ScreenCaptureKit and virtual-display lifecycle boundaries
- Metal viewport shader packaged with the app
- Linux core CI + native macOS app/Metal CI
- unit tests and CLI simulation

Run the hardware-independent pieces now:

```bash
swift test
swift run aer-sim
swift build --product AERMac
```

## Target macOS stack

```text
Air IMU ─────────────┐
Synthetic pose ──────┴─> HeadPoseSource ──> AERCore tracking
                                             │
CGVirtualDisplay ──> ScreenCaptureKit ───────┤
                                             v
                                            Metal
                                             │
                                             v
                                    XREAL Air display
```

The macOS menu-bar app is designed around:

- **Anchor** — world-ish fixed 3DoF display
- **Follow** — damped head-following display
- **Recenter** shortcut
- display size/distance presets
- ultrawide and workspace presets
- brightness / refresh controls where hardware permits
- smoothing and motion-prediction tuning
- software gamma, RGB, contrast and sharpening controls

The synthetic pose controls are intentionally upstream of the compositor so they can be replaced by the physical Air IMU without redesigning rendering.

## Hardware target

```text
Vendor ID      0x3318
Product ID     0x0424
IMU interface  3
MCU interface  4
```

These values come from the MIT-licensed `xrealair-sdk-macos` community driver and will be verified against the physical pair on arrival.

## Principles

1. **Stock firmware first.** No flashing until the hardware is fully tested.
2. **Read before write.** Normal tracking code must not contain MCU/firmware writes.
3. **Record before tuning.** Real IMU captures become regression fixtures.
4. **Separate risky operations.** Firmware experiments never belong in the normal spatial app.
5. **Mac first.** Get excellent 3DoF on macOS before attempting Android.
6. **Measure latency.** Spatial comfort is a systems problem, not just a smoothing slider.
7. **Local by default.** Screen/camera/motion data stays on the device unless explicitly exported.

## Project docs

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
- [`docs/INPUT_ARCHITECTURE.md`](docs/INPUT_ARCHITECTURE.md)
- [`docs/ROADMAP.md`](docs/ROADMAP.md)
- [`docs/HARDWARE_ARRIVAL.md`](docs/HARDWARE_ARRIVAL.md)
- [`docs/PROTOCOL_NOTES.md`](docs/PROTOCOL_NOTES.md)
- [`docs/PRIVACY_PERMISSIONS.md`](docs/PRIVACY_PERMISSIONS.md)
- [`docs/THIRD_PARTY.md`](docs/THIRD_PARTY.md)
- [`docs/REFERENCES.md`](docs/REFERENCES.md)

## Name

*AER* is Latin (via Greek) for **air**.

## License

MIT. See `docs/THIRD_PARTY.md` before vendoring external source.
