# Roadmap

## Phase 0 — before the glasses arrive

- [x] Establish project architecture.
- [x] Record verified Air 1 USB identifiers.
- [x] Implement platform-neutral vector/quaternion math.
- [x] Implement 6-axis Madgwick orientation filter.
- [x] Implement synthetic IMU input for development without hardware.
- [x] Implement deterministic orientation → viewport mapping.
- [x] Add tests and CLI simulation.
- [ ] Create the macOS application/Xcode target.
- [ ] Add virtual display wrapper.
- [ ] Add ScreenCaptureKit capture skeleton.
- [ ] Add Metal renderer skeleton.
- [ ] Add a replay-file IMU source (`.aerimu`) so real sessions can become regression tests.

## Phase 1 — arrival day

- [ ] Physical inspection: temples, hinges, lenses, nose pads, cable.
- [ ] Confirm Air enumerates as USB VID `0x3318`, PID `0x0424`.
- [ ] Confirm external display at stock 1920×1080.
- [ ] Confirm MCU + IMU HID interfaces are accessible.
- [ ] Capture 30 seconds of raw stationary IMU data.
- [ ] Capture controlled yaw/pitch/roll recordings.
- [ ] Determine sensor axis order, signs and units.
- [ ] Add hardware calibration transform.
- [ ] Measure real IMU sample rate and jitter.

## Phase 2 — first spatial prototype

- [ ] Live head orientation in menu bar debug view.
- [ ] Global recenter shortcut.
- [ ] Anchor mode with 3840×2160 virtual canvas.
- [ ] Follow mode with adjustable damping.
- [ ] Clamp/wrap behaviour at virtual-canvas edges.
- [ ] Latency instrumentation from IMU sample → rendered frame.

**Exit criterion:** comfortably read code for 30 minutes while turning the head naturally, without obvious swimming or judder.

## Phase 3 — make it pleasant

- [ ] Per-user calibration profile.
- [ ] Adaptive smoothing based on angular velocity.
- [ ] 1-frame motion prediction.
- [ ] Screen distance / size abstractions.
- [ ] Curved ultrawide mode.
- [ ] Multi-monitor/workspace presets.
- [ ] Hardware brightness controls.
- [ ] Refresh-rate controls.
- [ ] Software gamma/contrast/RGB/sharpening controls.

## Phase 4 — experiments

- [ ] Webcam-assisted X/Y/Z head position.
- [ ] IMU + Vision head-pose fusion.
- [ ] 1920×1200 Air 1 firmware experiment on a fully recoverable setup only.
- [ ] Pixel/Android proof-of-concept after Mac behaviour is mature.
