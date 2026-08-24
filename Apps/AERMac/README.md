# AERMac

The shipping macOS menu-bar application will live here.

The platform-independent tracking core is being built first so we can test pose handling and viewport behaviour before the glasses arrive.

Planned macOS layers:

1. **AERHardwareMac** — XREAL USB HID discovery + IMU/MCU bridge.
2. **AERVirtualDisplay** — `CGVirtualDisplay` lifecycle and resolution presets.
3. **AERCapture** — ScreenCaptureKit capture of the virtual canvas.
4. **AERRenderer** — Metal crop/warp/sharpen pipeline onto the physical Air display.
5. **AERMenuBar** — device status, anchor/follow modes, recenter, brightness, refresh, tuning profiles.

`CGVirtualDisplay` is private API, so AER is expected to be distributed outside the Mac App Store.
