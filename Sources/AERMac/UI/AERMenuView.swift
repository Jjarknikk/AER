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
        .frame(width: 320)
    }
}
#endif
