#if os(macOS)
import Metal

/// Owns the GPU resources for the final ScreenCaptureKit -> Metal -> Air path.
/// The first milestone is deliberately modest: prove that a device, queue and
/// shader library can be created before connecting captured IOSurfaces.
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
            shaderLibrary = try device.makeLibrary(source: Self.shaderSource, options: nil)
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

    private static let shaderSource = #"""
    #include <metal_stdlib>
    using namespace metal;

    struct VertexOut {
        float4 position [[position]];
        float2 uv;
    };

    vertex VertexOut aerVertex(uint vertexID [[vertex_id]]) {
        constexpr float2 positions[3] = {
            float2(-1.0, -1.0),
            float2( 3.0, -1.0),
            float2(-1.0,  3.0)
        };
        constexpr float2 uvs[3] = {
            float2(0.0, 1.0),
            float2(2.0, 1.0),
            float2(0.0, -1.0)
        };
        VertexOut out;
        out.position = float4(positions[vertexID], 0.0, 1.0);
        out.uv = uvs[vertexID];
        return out;
    }

    fragment float4 aerCrop(
        VertexOut in [[stage_in]],
        texture2d<float> source [[texture(0)]],
        sampler sourceSampler [[sampler(0)]],
        constant float2 &viewportOrigin [[buffer(0)]],
        constant float2 &viewportSize [[buffer(1)]]) {
        float2 uv = viewportOrigin + in.uv * viewportSize;
        return source.sample(sourceSampler, uv);
    }
    """#
}
#endif
