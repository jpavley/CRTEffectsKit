//
//  ScanlineFlicker.swift
//  CRTEffectsKit
//
//  Animated scanline intensity for enhanced CRT realism.
//
//  Created by Claude Code on 12/15/24.
//

import SwiftUI
import Combine

// MARK: - Configuration

/// Configuration for scanline flicker animation effect.
public struct ScanlineFlickerConfig: Sendable {
    /// Enable/disable the flicker effect.
    public var enabled: Bool

    /// Base scanline intensity (center point of fluctuation).
    /// Range: 0.0-0.5
    public var baseIntensity: Float

    /// How much intensity varies from base (+/-).
    /// Range: 0.0-0.2 (e.g., 0.05 means intensity varies by +/-0.05)
    public var intensityRange: Float

    /// Minimum seconds between flicker changes.
    public var minInterval: Double

    /// Maximum seconds between flicker changes.
    public var maxInterval: Double

    /// Duration of the ease animation (seconds).
    public var animationDuration: Double

    /// Creates a scanline flicker configuration.
    ///
    /// - Parameters:
    ///   - enabled: Enable/disable flicker
    ///   - baseIntensity: Center point of intensity fluctuation (0.0-0.5)
    ///   - intensityRange: Variation from base (+/-, 0.0-0.2)
    ///   - minInterval: Minimum seconds between changes
    ///   - maxInterval: Maximum seconds between changes
    ///   - animationDuration: Duration of transitions
    public init(
        enabled: Bool,
        baseIntensity: Float,
        intensityRange: Float,
        minInterval: Double,
        maxInterval: Double,
        animationDuration: Double
    ) {
        self.enabled = enabled
        self.baseIntensity = baseIntensity
        self.intensityRange = intensityRange
        self.minInterval = minInterval
        self.maxInterval = maxInterval
        self.animationDuration = animationDuration
    }
}

// MARK: - Presets

extension ScanlineFlickerConfig {
    /// Flicker disabled.
    public static let disabled = ScanlineFlickerConfig(
        enabled: false,
        baseIntensity: 0.15,
        intensityRange: 0,
        minInterval: 1,
        maxInterval: 3,
        animationDuration: 0.5
    )

    /// Subtle, barely noticeable flicker.
    public static let subtle = ScanlineFlickerConfig(
        enabled: true,
        baseIntensity: 0.15,
        intensityRange: 0.03,
        minInterval: 3,
        maxInterval: 8,
        animationDuration: 1.0
    )

    /// Moderate flicker - noticeable but not distracting.
    public static let moderate = ScanlineFlickerConfig(
        enabled: true,
        baseIntensity: 0.15,
        intensityRange: 0.05,
        minInterval: 2,
        maxInterval: 6,
        animationDuration: 0.8
    )

    /// Pronounced flicker - old unstable CRT feel.
    public static let unstable = ScanlineFlickerConfig(
        enabled: true,
        baseIntensity: 0.30,
        intensityRange: 0.25,
        minInterval: 1,
        maxInterval: 4,
        animationDuration: 0.5
    )

    /// Rapid flicker - very old/damaged CRT.
    public static let damaged = ScanlineFlickerConfig(
        enabled: true,
        baseIntensity: 0.12,
        intensityRange: 0.10,
        minInterval: 0.5,
        maxInterval: 2,
        animationDuration: 0.3
    )
}

// MARK: - Flicker Manager

/// Manages the scanline flicker animation loop.
///
/// ## Example Usage
///
/// ```swift
/// @StateObject private var flickerManager = ScanlineFlickerManager(config: .subtle)
///
/// var body: some View {
///     MyView()
///         .crtEffect(
///             config: .authentic,
///             size: geometry.size,
///             scanlineIntensity: flickerManager.currentIntensity
///         )
///         .onAppear { flickerManager.startFlicker() }
///         .onDisappear { flickerManager.stopFlicker() }
/// }
/// ```
@MainActor
public class ScanlineFlickerManager: ObservableObject {
    /// Current scanline intensity (animated).
    @Published public private(set) var currentIntensity: Float = 0.15

    /// Current configuration.
    public var config: ScanlineFlickerConfig {
        didSet {
            currentIntensity = config.baseIntensity
            if config.enabled && !isRunning {
                startFlicker()
            } else if !config.enabled {
                stopFlicker()
            }
        }
    }

    private var flickerTask: Task<Void, Never>?
    private var isRunning = false

    /// Creates a flicker manager with the specified configuration.
    ///
    /// - Parameter config: Flicker configuration preset or custom config
    public init(config: ScanlineFlickerConfig) {
        self.config = config
        self.currentIntensity = config.baseIntensity
    }

    /// Start the flicker animation loop.
    public func startFlicker() {
        guard config.enabled else { return }
        guard !isRunning else { return }

        isRunning = true

        flickerTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self = self, self.isRunning else { break }

                // Random wait interval
                let interval = Double.random(in: self.config.minInterval...self.config.maxInterval)
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))

                guard !Task.isCancelled, self.isRunning else { break }

                // Calculate random target intensity within range
                let variation = Float.random(in: -self.config.intensityRange...self.config.intensityRange)
                let targetIntensity = max(0, self.config.baseIntensity + variation)

                // Update intensity (triggers SwiftUI re-render)
                self.currentIntensity = targetIntensity
            }
        }
    }

    /// Stop the flicker animation loop.
    public func stopFlicker() {
        isRunning = false
        flickerTask?.cancel()
        flickerTask = nil

        // Reset to base intensity
        withAnimation(.easeOut(duration: 0.3)) {
            currentIntensity = config.baseIntensity
        }
    }

    deinit {
        flickerTask?.cancel()
    }
}
