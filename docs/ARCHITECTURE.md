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
                             orientation + prediction    │
                                      │                  │
CGVirtualDisplay ──> ScreenCaptureKit ──> Metal compositor
                                      │
                                      v
                           fullscreen Air 1 output
```

## Module boundaries

### AERCore
Pure Swift, no AppKit/Metal/IOKit. Contains:

- IMU sample model
- quaternion/vector math
- Madgwick 6-axis orientation filter
- calibration-neutral yaw/pitch/roll representation
- spatial profile values
- orientation-to-viewport mapping
- deterministic synthetic motion data

This core compiles and tests without physical hardware.

### AERHardwareMac
Mac-only HID layer. Initial implementation should wrap proven MIT-licensed community protocol work rather than reverse-engineer every packet again.

Hardware coordinate transforms belong here. `AERCore` must not assume the XREAL sensor's native axis order/sign.

### AERVirtualDisplay
Creates the larger macOS canvas. Initial target is 3840×2160 with a 1920×1080 physical viewport.

### AERCapture
ScreenCaptureKit captures the virtual display into IOSurfaces.

### AERRenderer
Metal renders the moving viewport to the glasses. Eventually this layer can also provide:

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

That should be treated as an optional tracking source, never a dependency of the base spatial mode.
