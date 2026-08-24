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
