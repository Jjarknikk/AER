# Reference implementations

These are research inputs, not dependencies yet.

## UltraXReal

- Repository: https://github.com/DannyDesert/XReal-Ultrawide
- License: MIT
- macOS menu-bar app
- Uses `CGVirtualDisplay`, ScreenCaptureKit and Metal
- Current README describes a 3840×2160 spatial canvas, 1920×1080 moving viewport, XREAL HID IMU input and Madgwick sensor fusion

AER differs by making tracking, capture and hardware adapters independently testable from the beginning, and by treating recorded IMU sessions as regression fixtures.

## xrealair-sdk-macos

- Repository: https://github.com/adidoes/xrealair-sdk-macos
- License: MIT
- C implementation of XREAL Air HID/IMU/MCU communication on macOS
- Useful starting point for the hardware adapter

## Breezy Desktop

- Repository: https://github.com/wheaney/breezy-desktop
- Linux spatial desktop project
- Useful reference for tracking UX, multi-display behaviour and motion handling

## Licensing rule

If AER copies or vendors MIT-licensed source, retain the original copyright and permission notice in the copied source/subtree. Architectural ideas can be reimplemented independently, but code should never be copied without attribution.
