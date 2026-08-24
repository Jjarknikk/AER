# Spatial input architecture

AER treats tracking and interaction sources as replaceable inputs rather than hard-coding them into the renderer.

```text
Air IMU ───────────────┐
Synthetic pose ────────┼─> HeadPoseSource ───────┐
                       │                          │
Mac camera (future) ───┴─> TranslationSource ───┼─> spatial state / interaction
                                                  │
Vision / Leap (future) ─> HandPoseSource ────────┤
Gesture recognizer ─────> GestureSource ─────────┘
```

## HeadPoseSource

Provides timestamped yaw/pitch/roll orientation and optional angular velocity. Initial implementations:

- synthetic manual source for pre-hardware development;
- Air 1 IMU + sensor fusion after hardware calibration.

## TranslationSource

Provides XYZ translation in metres. Air 1 cannot provide this itself. A future desk-only implementation may use Mac camera head pose.

## HandPoseSource

Provides named hand joints in a calibrated coordinate space. Future candidates include Apple Vision hand-pose detection from a webcam and a dedicated Ultraleap sensor.

## GestureSource

Provides semantic events such as pinch, grab, point and scroll. Gesture recognition must remain separate from hand-pose acquisition so different sensors can use the same interaction router.

## Rule

Rendering must not depend directly on a specific sensor SDK. Input sources publish normalized AER data structures, and calibration/adaptation happens at the source boundary.
