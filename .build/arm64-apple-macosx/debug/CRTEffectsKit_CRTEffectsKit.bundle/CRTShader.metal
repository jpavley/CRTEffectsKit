//
//  CRTShader.metal
//  CRTEffectsKit
//
//  GPU-accelerated CRT monitor visual effects.
//
//  Created by Claude Code on 12/14/24.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

// MARK: - Barrel Distortion (Screen Curve)
// Distorts pixel positions to create the curved screen effect of a CRT monitor
// intensity: 0.0 = none, 0.1-0.3 = subtle, 0.5+ = pronounced
[[stitchable]] float2 barrelDistortion(
    float2 position,
    float2 size,
    float intensity
) {
    // Convert to UV coordinates (0-1 range)
    float2 uv = position / size;

    // Center the coordinates (-0.5 to 0.5)
    float2 centered = uv - 0.5;

    // Calculate distance from center (squared for barrel effect)
    float dist = dot(centered, centered);

    // Apply barrel distortion
    float2 distorted = centered * (1.0 + intensity * dist);

    // Convert back to pixel coordinates
    return (distorted + 0.5) * size;
}

// MARK: - Vignette (Darkened Edges)
// Darkens pixels near screen edges, creating the characteristic CRT falloff
// intensity: 0.0-1.0, how dark edges get
// radius: 0.5-1.5, where falloff begins (higher = falloff starts further from center)
[[stitchable]] half4 vignette(
    float2 position,
    half4 color,
    float2 size,
    float intensity,
    float radius
) {
    // Convert to UV coordinates
    float2 uv = position / size;

    // Center the coordinates
    float2 centered = uv - 0.5;

    // Calculate distance from center (0 at center, ~0.7 at corners)
    float dist = length(centered) * 2.0;

    // Create smooth falloff using smoothstep
    float vig = smoothstep(radius, radius - 0.5, dist);

    // Calculate darkening factor
    float factor = mix(1.0 - intensity, 1.0, vig);

    // Apply to color while preserving alpha
    return half4(color.rgb * factor, color.a);
}

// MARK: - Scanlines
// Adds horizontal line pattern simulating CRT electron beam scanning
// spacing: pixels between lines (2-6 typical)
// intensity: 0.0-1.0, line darkness (0.1-0.2 is usually subtle enough)
[[stitchable]] half4 scanlines(
    float2 position,
    half4 color,
    float spacing,
    float intensity
) {
    // Create sine wave pattern based on vertical position
    float scanline = sin(position.y * 3.14159265 / spacing);

    // Convert sine wave (-1 to 1) to darkening factor
    // scanline = 1 at peaks, -1 at troughs
    // We want slight darkening at troughs
    float factor = 1.0 - (intensity * 0.5 * (1.0 - scanline));

    // Apply to color while preserving alpha
    return half4(color.rgb * factor, color.a);
}

// MARK: - Phosphor Glow (Bloom Effect)
// Adds bloom/glow around bright pixels, simulating CRT phosphor persistence
// intensity: 0.0-1.0, glow strength
// samples: blur sample count (not currently used, radius is fixed for performance)
[[stitchable]] half4 phosphorGlow(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float intensity,
    float samples
) {
    // Sample the original color
    half4 color = layer.sample(position);

    // Accumulate neighboring pixels for blur/glow effect
    half4 glow = half4(0);
    float radius = 2.0;
    float sampleCount = 0.0;

    // Sample in a grid pattern around the current pixel
    for (float x = -radius; x <= radius; x += 1.0) {
        for (float y = -radius; y <= radius; y += 1.0) {
            glow += layer.sample(position + float2(x, y));
            sampleCount += 1.0;
        }
    }

    // Average the samples
    glow /= sampleCount;

    // Blend original color with glow
    // The glow adds to bright areas, creating bloom effect
    return mix(color, color + glow * intensity, intensity);
}
