# XREAL protocol notes

## Verified identifiers

The MIT-licensed `xrealair-sdk-macos` project records the following HID identifiers:

| Model | VID | PID | IMU interface | MCU interface |
|---|---:|---:|---:|---:|
| XREAL/Nreal Air | `0x3318` | `0x0424` | 3 | 4 |
| XREAL Air 2 | `0x3318` | `0x0428` | 3 | 4 |

Source: `adidoes/xrealair-sdk-macos`, `src/hid_ids.c`.

## Implementation policy

AER should not casually duplicate opaque MCU/IMU packet parsing. The first hardware implementation should either:

1. vendor a small, audited subset of an MIT-licensed driver with original notices retained, or
2. wrap that C driver behind a narrow Swift API.

The Swift-facing boundary should expose normalized values only:

```swift
IMUSample(
    timestamp: monotonicSeconds,
    gyro: radiansPerSecond,
    accelerometer: gUnits
)
```

This keeps packet layouts and scale factors out of the compositor/tracking code.

## Safety boundary

Read-only IMU work and normal MCU settings are separate from firmware flashing.

AER v0.x should not contain a firmware flasher. Any later 1200p experiment should be a separate opt-in tool with explicit model/firmware validation and recovery documentation.
