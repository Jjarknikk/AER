# Third-party code and references

AER is MIT licensed. Keep copied/vendor source distinct from code that is merely studied as a reference.

## Currently vendored

**None.** The current tracking/filter implementation and application scaffold are AER source.

## Planned integration candidates

### xrealair-sdk-macos

- Repository: `adidoes/xrealair-sdk-macos`
- License: MIT
- Purpose: proven XREAL Air HID/IMU protocol behaviour on macOS.
- Rule: if source is copied or vendored, retain its copyright and MIT notice in the vendored directory.

### Fusion / xioTechnologies

- Purpose: possible comparison/reference for production sensor-fusion tuning.
- Status: not currently vendored; AER currently contains its own small 6-axis Madgwick implementation.

## Architectural references only

These projects may inform design without source being copied:

- UltraXReal / XReal-Ultrawide — macOS virtual display, ScreenCaptureKit and spatial-display architecture.
- Breezy Desktop — spatial desktop/input ideas on Linux.
- BetterDisplay / FluffyDisplay — virtual-display lifecycle patterns.

A reference in documentation does **not** grant permission to copy code under a different license. Check each dependency before importing any source.

## Apple APIs

AER expects to use Apple's ScreenCaptureKit, Metal, AppKit/SwiftUI and IOKit HID APIs. The proposed `CGVirtualDisplay` backend uses a private Apple API and therefore prevents Mac App Store distribution and may require maintenance across macOS releases.
