#if os(macOS)
import Foundation
import Metal

enum AERRendererError: LocalizedError {
    case shaderResourceMissing

    var errorDescription: String? {
        switch self {
        case .shaderResourceMissing:
            return "AERViewport.metal is missing from the app resources"
        }
    }
}

/// Owns the GPU resources for the ScreenCaptureKit -> Metal -> Air path.
///
/// The Metal source lives as a package resource so the exact shader used by the
/// app is also compiled independently by macOS CI with `xcrun metal`.
final class MetalViewportRenderer {
    private(set) var device: MTLDevice?
    private(set) var commandQueue: MTLCommandQueue?
    private(set) var shaderLibrary: MTLLibrary?
    private(set) var initializationError: Error?

    init() {
        guard let device = MTLCreateSystemDefaultDevice() else { return }
        self.device = device
        commandQueue = device.makeCommandQueue()

        do {
            guard let shaderURL = Bundle.module.url(forResource: "AERViewport", withExtension: "metal") else {
                throw AERRendererError.shaderResourceMissing
            }
            let source = try String(contentsOf: shaderURL, encoding: .utf8)
            shaderLibrary = try device.makeLibrary(source: source, options: nil)
        } catch {
            initializationError = error
        }
    }

    var statusDescription: String {
        if let initializationError {
            return "Metal shader error: \(initializationError.localizedDescription)"
        }
        guard device != nil, commandQueue != nil, shaderLibrary != nil else {
            return "Metal unavailable"
        }
        return "Metal renderer ready"
    }
}
#endif
