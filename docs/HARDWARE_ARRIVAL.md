# Air 1 arrival checklist

Do **not** flash firmware during initial testing.

## 1. Inspect before wearing

- Photograph both temple arms, especially the hinge/arm transition.
- Look for hairline cracks under strong side lighting.
- Check USB-C socket for looseness or deformation.
- Check both optical combiner lenses for chips or deep scratches.
- Confirm the supplied cable has no hard kinks near either connector.

## 2. Establish a stock baseline

On macOS:

```bash
system_profiler SPDisplaysDataType
system_profiler SPUSBDataType
```

Record the output under `captures/<date>/baseline/`.

Expected Air 1 USB identity from community drivers:

- Vendor ID: `0x3318`
- Product ID: `0x0424`
- IMU interface: `3`
- MCU interface: `4`

Then verify:

- 1920×1080 output
- 60 Hz
- 120 Hz if exposed by stock firmware/macOS
- brightness buttons
- audio left/right
- all four corners readable with small text

## 3. Capture IMU truth data

The first raw recordings should be deliberately boring:

1. 30 s stationary on a desk.
2. 10 slow yaw rotations left/right, returning to centre.
3. 10 slow pitch movements up/down.
4. 10 slow roll movements.
5. Normal head movement for 60 s.

These captures become fixtures for filter tuning; never tune exclusively against live perception.

## 4. Only then enable spatial rendering

First target:

- stock firmware
- 1080p
- 60/120 Hz as available
- no image enhancements
- no camera tracking

Get clean 3DoF anchoring first. Add clever features later.
