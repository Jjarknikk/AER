# Architecture

## Goal

AER is a Mac-first spatial desktop for the original XREAL/Nreal Air (NR-7100RGL), designed to work without XREAL Beam hardware.

The first usable target is simple and measurable:

> Connect Air 1 directly to a Mac, press **Anchor**, and have a normal macOS desktop remain visually stable while the user's head rotates.

Everything else is layered on after that works reliably.

## Pipeline

```text
XREAL Air 1
  ├─ DisplayPort alt-mode ───────────────────────────────┐
  └─ USB HID IMU ──> Hardware adapter ──> pose filter   │
                                      │                  │
                                      v                  │
                              HeadPoseSource             │
                                      │                  │
                                      v                  │
                             orientation + prediction    │
                                      │                  │
CGVirtualDisplay ──> ScreenCaptureKit ──> Metal compositor
                                      │
                                      v
                           fullscreen Air 1 output
```

Before hardware arrives, `SyntheticHeadPoseSource` replaces the Air branch. This lets us validate pose mapping and compositor behaviour without changing the downstream architecture.

## Module boundaries

### AERCore

Pure Swift, no AppKit/Metal/IOKit. Contains:

- IMU sample and `.aerimu` recording models
- quaternion/vector math
- Madgwick 6-axis orientation filter
- calibration-neutral yaw/pitch/roll representation
- spatial profile values
- orientation-to-viewport mapping
- deterministic synthetic motion data
- normalized spatial input contracts

This core compiles and tests without physical hardware.

### AERHardwareMac

Mac-only HID layer. The pre-hardware implementation is deliberately read-only: it discovers the known Air 1 VID/PID, detects interface appearance/disappearance and provides a raw-report logging boundary.

The production IMU decoder should wrap proven MIT-licensed community protocol work rather than reverse-engineer every packet from scratch. Hardware coordinate transforms belong here. `AERCore` must not assume the XREAL sensor's native axis order/sign.

### AERInput

All tracking/interaction providers normalize into source protocols:

- `HeadPoseSource` — rotational pose; synthetic now, Air IMU later.
- `TranslationSource` — optional XYZ translation; future webcam desk tracking.
- `HandPoseSource` — optional hand joints; future Vision/Ultraleap.
- `GestureSource` — semantic interaction events independent of the hand sensor.

The renderer must never depend directly on a specific sensor SDK.

### AERVirtualDisplay

Creates the larger macOS canvas. Initial target is 3840×2160 with a 1920×1080 physical viewport. `CGVirtualDisplay` is private API and remains isolated behind a small lifecycle coordinator.

### AERCapture

ScreenCaptureKit captures the virtual display into GPU-friendly surfaces.

### AERRenderer

Metal renders the moving viewport to the glasses. The shader is a real package resource and is independently compiled in macOS CI. Eventually this layer can also provide:

- sub-frame pose updates
- motion prediction
- sharpening
- gamma / RGB curves
- vignette and edge masks
- optional barrel/chromatic corrections

## Tracking conventions

The core uses radians and a Z-Y-X Tait-Bryan orientation representation:

- yaw: rotation about Z
- pitch: rotation about Y
- roll: rotation about X

This is an internal convention, not a claim about XREAL's raw packet axes. A hardware calibration matrix will translate the actual sensor orientation.

## 3DoF versus 6DoF

Air 1 supplies rotation, not absolute translation. AER v1 therefore targets excellent 3DoF anchoring.

A later experimental desk-only 6DoF mode can fuse:

- Air IMU for low-latency rotation
- Mac camera head pose for X/Y/Z translation

That translation is an optional `TranslationSource`, never a dependency of the base spatial mode.
