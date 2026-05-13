//
//  CRTModifier.swift
//  CRTEffectsKit
//
//  GPU-accelerated CRT monitor visual effects for SwiftUI.
//
//  Created by Claude Code on 12/14/24.
//

import SwiftUI

/// View modifier that applies CRT shader effects.
public struct CRTEffectModifier: ViewModifier {
    let config: CRTConfig
    let size: CGSize
    var scanlineIntensityOverride: Float?  // Optional override for animated scanlines

    // Effective scanline intensity (uses override if provided)
    private var effectiveScanlineIntensity: Float {
        scanlineIntensityOverride ?? config.scanlineIntensity
    }

    /// Creates a CRT effect modifier.
    ///
    /// - Parameters:
    ///   - config: CRT configuration with effect parameters
    ///   - size: Screen/container size for shader calculations
    ///   - scanlineIntensityOverride: Optional override for scanline intensity (for animation)
    public init(config: CRTConfig, size: CGSize, scanlineIntensityOverride: Float? = nil) {
        self.config = config
        self.size = size
        self.scanlineIntensityOverride = scanlineIntensityOverride
    }

    // Use the package's bundle for shader access
    private static let shaderLibrary = ShaderLibrary.bundle(.module)

    public func body(content: Content) -> some View {
        if config.enabled {
            content
                // Scanlines stamped in source/content space so the barrel pass
                // below warps them into a curve matching the screen edge.
                .colorEffect(
                    Self.shaderLibrary.scanlines(
                        .float(config.scanlineSpacing),
                        .float(effectiveScanlineIntensity)
                    ),
                    isEnabled: config.scanlinesEnabled
                )
                // Barrel distortion samples the scanlined intermediate, so
                // bands bow with the screen instead of staying flat.
                .distortionEffect(
                    Self.shaderLibrary.barrelDistortion(
                        .float2(Float(size.width), Float(size.height)),
                        .float(config.barrelIntensity)
                    ),
                    maxSampleOffset: CGSize(width: 30, height: 30),
                    isEnabled: config.barrelEnabled
                )
                // Vignette darkens the actual visible corners — must run in
                // post-distortion screen space.
                .colorEffect(
                    Self.shaderLibrary.vignette(
                        .float2(Float(size.width), Float(size.height)),
                        .float(config.vignetteIntensity),
                        .float(config.vignetteRadius)
                    ),
                    isEnabled: config.vignetteEnabled
                )
                // Glow blooms neighboring output pixels — also screen space.
                .layerEffect(
                    Self.shaderLibrary.phosphorGlow(
                        .float2(Float(size.width), Float(size.height)),
                        .float(config.glowIntensity),
                        .float(5)  // sample count
                    ),
                    maxSampleOffset: CGSize(width: 3, height: 3),
                    isEnabled: config.glowEnabled
                )
                // Apply rounded corner mask for CRT screen shape (with inset for clean edges)
                .padding(config.screenInset)
                .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius, style: .continuous))
        } else {
            content
        }
    }
}

// MARK: - View Extension

extension View {
    /// Apply CRT monitor visual effects.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// GeometryReader { geometry in
    ///     MyGameView()
    ///         .crtEffect(config: .authentic, size: geometry.size)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - config: CRT configuration with effect parameters
    ///   - size: Screen/container size for shader calculations
    ///   - scanlineIntensity: Optional override for scanline intensity (for animation)
    /// - Returns: Modified view with CRT effects applied
    public func crtEffect(config: CRTConfig, size: CGSize, scanlineIntensity: Float? = nil) -> some View {
        modifier(CRTEffectModifier(config: config, size: size, scanlineIntensityOverride: scanlineIntensity))
    }
}
