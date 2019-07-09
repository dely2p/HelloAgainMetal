//
//  Shaders.metal
//  FillTheTexture
//
//  Created by dely on 09/07/2019.
//  Copyright © 2019 dely. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    packed_float3 position;
    packed_float4 color;
};

struct VertexOut {
    float4 computedPosition [[position]];
    float4 color;
};

vertex VertexOut basic_vertex(const device VertexIn* vertex_array [[ buffer(0) ]], unsigned int vid [[ vertex_id ]]) {
    VertexIn v = vertex_array[vid];
    VertexOut outVertex = VertexOut();
    outVertex.computedPosition = float4(v.position, 1.0);
    outVertex.color = v.color;
    return outVertex;
}

fragment float4 basic_fragment(VertexOut interpolated [[stage_in]]) {
    return float4(interpolated.color);
}
