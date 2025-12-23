//
//  CRTConfig.swift
//  CRTEffectsKit
//
//  GPU-accelerated CRT monitor visual effects for SwiftUI.
//
//  Created by Claude Code on 12/14/24.
//

import SwiftUI

/// Configuration for CRT shader effects.
///
/// Use the provided presets (`.authentic`, `.subtle`, `.performance`, etc.) or create
/// custom configurations by adjusting individual parameters.
///
/// ## Example Usage
///
/// ```swift
/// // Using a preset
/// view.crtEffect(config: .authentic, size: geometry.size)
///
/// // Creating a custom config
/// var custom = CRTConfig.subtle
/// custom.scanlineIntensity = 0.2
/// view.crtEffect(config: custom, size: geometry.size)
/// ```
public struct CRTConfig {

    // MARK: - Master Toggle

    /// Enable/disable all CRT effects.
    public var enabled: Bool

    // MARK: - Barrel Distortion (screen curve)

    /// Enable barrel distortion effect.
    public var barrelEnabled: Bool
    /// Distortion intensity (Range: 0.0-0.5, where 0.1-0.2 is subtle).
    public var barrelIntensity: Float

    // MARK: - Vignette (dark edges)

    /// Enable vignette effect.
    public var vignetteEnabled: Bool
    /// How dark the edges become (Range: 0.0-1.0).
    public var vignetteIntensity: Float
    /// Where the falloff begins (Range: 0.5-1.5, higher = starts further from center).
    public var vignetteRadius: Float

    // MARK: - Scanlines

    /// Enable scanline effect.
    public var scanlinesEnabled: Bool
    /// Pixels between scanlines (Range: 2-6).
    public var scanlineSpacing: Float
    /// Scanline darkness (Range: 0.0-0.5, keep subtle).
    public var scanlineIntensity: Float

    // MARK: - Phosphor Glow

    /// Enable phosphor glow/bloom effect (more expensive).
    public var glowEnabled: Bool
    /// Glow strength (Range: 0.0-1.0).
    public var glowIntensity: Float

    // MARK: - Screen Shape

    /// Corner radius for rounded CRT screen edges (0 = square corners).
    public var cornerRadius: CGFloat
    /// Inset from edges before clipping (helps with barrel distortion artifacts).
    public var screenInset: CGFloat

    // MARK: - Initializer

    /// Creates a custom CRT configuration.
    ///
    /// - Parameters:
    ///   - enabled: Master toggle for all effects
    ///   - barrelEnabled: Enable barrel distortion
    ///   - barrelIntensity: Distortion strength (0.0-0.5)
    ///   - vignetteEnabled: Enable vignette effect
    ///   - vignetteIntensity: Edge darkening (0.0-1.0)
    ///   - vignetteRadius: Falloff start point (0.5-1.5)
    ///   - scanlinesEnabled: Enable scanlines
    ///   - scanlineSpacing: Pixels between lines (2-6)
    ///   - scanlineIntensity: Line darkness (0.0-0.5)
    ///   - glowEnabled: Enable phosphor glow
    ///   - glowIntensity: Glow strength (0.0-1.0)
    ///   - cornerRadius: Screen corner radius
    ///   - screenInset: Edge inset for clean clipping
    public init(
        enabled: Bool,
        barrelEnabled: Bool,
        barrelIntensity: Float,
        vignetteEnabled: Bool,
        vignetteIntensity: Float,
        vignetteRadius: Float,
        scanlinesEnabled: Bool,
        scanlineSpacing: Float,
        scanlineIntensity: Float,
        glowEnabled: Bool,
        glowIntensity: Float,
        cornerRadius: CGFloat,
        screenInset: CGFloat
    ) {
        self.enabled = enabled
        self.barrelEnabled = barrelEnabled
        self.barrelIntensity = barrelIntensity
        self.vignetteEnabled = vignetteEnabled
        self.vignetteIntensity = vignetteIntensity
        self.vignetteRadius = vignetteRadius
        self.scanlinesEnabled = scanlinesEnabled
        self.scanlineSpacing = scanlineSpacing
        self.scanlineIntensity = scanlineIntensity
        self.glowEnabled = glowEnabled
        self.glowIntensity = glowIntensity
        self.cornerRadius = cornerRadius
        self.screenInset = screenInset
    }
}

// MARK: - Presets

extension CRTConfig {

    /// All effects disabled.
    public static let disabled = CRTConfig(
        enabled: false,
        barrelEnabled: false,
        barrelIntensity: 0,
        vignetteEnabled: false,
        vignetteIntensity: 0,
        vignetteRadius: 0.8,
        scanlinesEnabled: false,
        scanlineSpacing: 3,
        scanlineIntensity: 0,
        glowEnabled: false,
        glowIntensity: 0,
        cornerRadius: 0,
        screenInset: 0
    )

    /// Light retro feel - good starting point.
    public static let subtle = CRTConfig(
        enabled: true,
        barrelEnabled: true,
        barrelIntensity: 0.08,
        vignetteEnabled: true,
        vignetteIntensity: 0.25,
        vignetteRadius: 0.9,
        scanlinesEnabled: true,
        scanlineSpacing: 3,
        scanlineIntensity: 0.08,
        glowEnabled: false,
        glowIntensity: 0,
        cornerRadius: 40,
        screenInset: 4
    )

    /// Full authentic CRT experience.
    public static let authentic = CRTConfig(
        enabled: true,
        barrelEnabled: true,
        barrelIntensity: 0.15,
        vignetteEnabled: true,
        vignetteIntensity: 0.40,
        vignetteRadius: 0.8,
        scanlinesEnabled: true,
        scanlineSpacing: 3,
        scanlineIntensity: 0.15,
        glowEnabled: true,
        glowIntensity: 0.3,
        cornerRadius: 0,
        screenInset: 8
    )

    /// Optimized for battery life - no glow, minimal barrel.
    public static let performance = CRTConfig(
        enabled: true,
        barrelEnabled: false,
        barrelIntensity: 0,
        vignetteEnabled: true,
        vignetteIntensity: 0.3,
        vignetteRadius: 0.85,
        scanlinesEnabled: true,
        scanlineSpacing: 4,
        scanlineIntensity: 0.1,
        glowEnabled: false,
        glowIntensity: 0,
        cornerRadius: 30,
        screenInset: 2
    )

    /// For dark/low-light conditions - full authentic CRT effect.
    public static let lowBrightness = CRTConfig(
        enabled: true,
        barrelEnabled: true,
        barrelIntensity: 0.15,
        vignetteEnabled: true,
        vignetteIntensity: 0.40,
        vignetteRadius: 0.8,
        scanlinesEnabled: true,
        scanlineSpacing: 3,
        scanlineIntensity: 0.15,
        glowEnabled: true,
        glowIntensity: 0.3,
        cornerRadius: 0,
        screenInset: 8
    )

    /// For bright/outdoor conditions - reduced vignette for readability.
    public static let highBrightness = CRTConfig(
        enabled: true,
        barrelEnabled: true,
        barrelIntensity: 0.15,
        vignetteEnabled: true,
        vignetteIntensity: 0.15,
        vignetteRadius: 0.95,
        scanlinesEnabled: true,
        scanlineSpacing: 3,
        scanlineIntensity: 0.08,
        glowEnabled: true,
        glowIntensity: 0.2,
        cornerRadius: 0,
        screenInset: 8
    )
}
