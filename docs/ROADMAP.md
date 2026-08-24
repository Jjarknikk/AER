# Roadmap

## Phase 0 — hardware-independent core

- [x] Establish project architecture.
- [x] Record verified Air 1 USB identifiers.
- [x] Implement platform-neutral vector/quaternion math.
- [x] Implement 6-axis Madgwick orientation filter.
- [x] Implement synthetic IMU input for development without hardware.
- [x] Implement deterministic orientation → viewport mapping.
- [x] Add tests and CLI simulation.
- [x] Create the macOS menu-bar application target.
- [x] Add virtual display lifecycle boundary.
- [x] Add ScreenCaptureKit permission/display-discovery skeleton.
- [x] Add Metal renderer skeleton.
- [x] Add `.aerimu` recording/replay model.

## Phase 0.5 — before the glasses arrive

- [x] Add native macOS CI that builds `AERMac` and compiles the Metal shader.
- [x] Add synthetic `HeadPoseSource` with mouse/slider and local keyboard controls.
- [x] Add synthetic pose → viewport preview state for Anchor/Follow development.
- [x] Add read-only Air 1 HID discovery / attach-detach monitor.
- [x] Add raw HID packet logging sink for arrival-day protocol captures.
- [x] Formalise `.aerimu` v2 metadata: device, units, timestamp source and calibration transform.
- [x] Ignore real hardware/motion captures by default.
- [x] Add generic head/translation/hand/gesture source interfaces.
- [x] Document privacy/permissions and third-party licensing boundaries.
- [ ] Wire the private `CGVirtualDisplay` backend behind `VirtualDisplayCoordinator`.
- [ ] Feed ScreenCaptureKit frames into the Metal viewport renderer.
- [ ] Render the synthetic pose crop live on a normal Mac display before Air hardware arrives.

## Phase 1 — arrival day

- [ ] Physical inspection: temples, hinges, lenses, nose pads, cable.
- [ ] Confirm Air enumerates as USB VID `0x3318`, PID `0x0424`.
- [ ] Confirm external display at stock 1920×1080.
- [ ] Confirm MCU + IMU HID interfaces are accessible.
- [ ] Capture raw HID reports from every Air interface before decoding assumptions are added.
- [ ] Capture 30 seconds of raw stationary IMU data.
- [ ] Capture controlled yaw/pitch/roll recordings.
- [ ] Determine sensor axis order, signs and units.
- [ ] Add hardware calibration transform.
- [ ] Measure real IMU sample rate and jitter.
- [ ] Populate `.aerimu` device/firmware metadata for the physical pair.

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
- [ ] 1-frame motion prediction tuning against measured latency.
- [ ] Screen distance / size abstractions.
- [ ] Curved ultrawide mode.
- [ ] Multi-monitor/workspace presets.
- [ ] Hardware brightness controls.
- [ ] Refresh-rate controls.
- [ ] Software gamma/contrast/RGB/sharpening controls.

## Phase 4 — experiments

- [ ] Webcam-assisted X/Y/Z head position through `TranslationSource`.
- [ ] IMU + Vision head-pose fusion.
- [ ] Vision webcam hand-pose source.
- [ ] Optional Ultraleap hand-pose source.
- [ ] Gesture → spatial display/window interaction router.
- [ ] 1920×1200 Air 1 firmware experiment on a fully recoverable setup only.
- [ ] Pixel/Android proof-of-concept after Mac behaviour is mature.
