#if os(macOS)
import SwiftUI

struct AERMenuView: View {
    @ObservedObject var model: AERAppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "eyeglasses")
                VStack(alignment: .leading, spacing: 2) {
                    Text("AER").font(.headline)
                    Text(model.statusMessage).font(.caption).foregroundStyle(.secondary)
                }
            }

            Picker("Spatial mode", selection: Binding(
                get: { model.mode },
                set: { model.setMode($0) }
            )) {
                ForEach(AERAppModel.SpatialMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                Button("Recenter") { model.recenter() }
                    .keyboardShortcut("r", modifiers: [.command, .shift])
                Spacer()
                Text("Prediction \(model.profile.predictionMilliseconds, specifier: "%.0f") ms")
                    .font(.caption.monospacedDigit())
            }

            Toggle("Synthetic head input", isOn: Binding(
                get: { model.syntheticPoseEnabled },
                set: { model.setSyntheticPoseEnabled($0) }
            ))

            if model.syntheticPoseEnabled {
                syntheticControls
            }

            if !model.screenCaptureAuthorised {
                Button("Allow Screen Capture") { model.requestScreenCapturePermission() }
            }

            Divider()

            Text("Canvas \(Int(model.virtualCanvas.width))×\(Int(model.virtualCanvas.height)) → 1920×1080")
                .font(.caption.monospacedDigit())
            Text(model.renderer.statusDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(width: 340)
    }

    private var syntheticControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(model.syntheticPoseDescription)
                .font(.caption.monospacedDigit())

            HStack {
                Text("Yaw").frame(width: 38, alignment: .leading)
                Slider(
                    value: Binding(
                        get: { model.syntheticOrientation.yawDegrees },
                        set: { model.setSyntheticPoseDegrees(yaw: $0) }
                    ),
                    in: -45...45
                )
            }

            HStack {
                Text("Pitch").frame(width: 38, alignment: .leading)
                Slider(
                    value: Binding(
                        get: { model.syntheticOrientation.pitchDegrees },
                        set: { model.setSyntheticPoseDegrees(pitch: $0) }
                    ),
                    in: -30...30
                )
            }

            HStack {
                Button("Reset pose") { model.resetSyntheticPose() }
                Spacer()
                Text(model.syntheticViewportDescription)
                    .font(.caption.monospacedDigit())
            }

            Text("Mouse: drag sliders  •  Keyboard: ⌥←/→ yaw, ⌥↑/↓ pitch, ⌥Q/E roll, ⌥0 recenter")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(8)
        .background(.quaternary.opacity(0.35), in: RoundedRectangle(cornerRadius: 8))
    }
}
#endif
