import Foundation
import AERCore

let args = Set(CommandLine.arguments.dropFirst())
let mode = args.contains("--stationary") ? "stationary" : "yaw"
let samples: [IMUSample]

if mode == "stationary" {
    samples = SyntheticIMU.stationary(duration: 3, sampleRate: 120)
} else {
    samples = SyntheticIMU.yawSweep(duration: 6, sampleRate: 120, amplitudeDegrees: 28, period: 4)
}

var engine = SpatialTrackingEngine()

print("t,yaw_deg,predicted_yaw_deg,pitch_deg,viewport_x,viewport_y")
for (index, sample) in samples.enumerated() {
    let frame = engine.process(sample)
    if index % 6 == 0 {
        print(String(format: "%.3f,%.3f,%.3f,%.3f,%.1f,%.1f",
            sample.timestamp,
            frame.orientation.yawDegrees,
            frame.predictedOrientation.yawDegrees,
            frame.orientation.pitchDegrees,
            frame.viewportOrigin.x,
            frame.viewportOrigin.y
        ))
    }
}
