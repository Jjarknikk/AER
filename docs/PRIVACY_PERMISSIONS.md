# Privacy and permissions

AER should work locally and offline. The base spatial path does not require an account, cloud service, analytics SDK or network telemetry.

## Screen Recording

**Why:** AER uses ScreenCaptureKit to capture the virtual macOS canvas before rendering the tracked viewport to the glasses.

**Data handling:** frames stay in local process/GPU memory. AER should not write captured screen frames to disk unless an explicit diagnostic capture feature is added later.

**Status:** required for spatial desktop rendering.

## Accessibility / Input Monitoring

**Why it may be needed later:** global recenter hotkeys, mouse-event injection, window manipulation or gesture-to-macOS input may require Accessibility/Input Monitoring depending on the final implementation.

The current synthetic keyboard driver is deliberately **local-only** while the AER menu has focus, so it does not need to act as a global key logger.

**Status:** not required for the current base tracking path.

## Camera

**Why it may be needed later:** optional webcam-assisted translation (desk pseudo-6DoF) and optional Vision hand-pose experiments.

Camera processing should be opt-in and local. AER v1 must not require camera access for normal Air 1 3DoF use.

**Status:** future optional experiment.

## Hardware and motion captures

Raw HID logs and `.aerimu` recordings may reveal motion patterns and hardware metadata. They are therefore ignored by git by default under `captures/` and `*.aerimu`.

Only deliberately curated regression fixtures should be added beneath `Tests/Fixtures/`.

## Network policy

AER currently has no runtime network requirement. If update checking or optional integrations are added later, they should be documented here before shipping.
