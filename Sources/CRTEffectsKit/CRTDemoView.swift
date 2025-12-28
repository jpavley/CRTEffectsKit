//
//  CRTDemoView.swift
//  CRTEffectsKit
//
//  Interactive demo view for previewing CRT effects and presets.
//  Use this to tune scanline intensity, spacing, and other parameters.
//
//  Created by Claude Code on 12/28/25.
//

import SwiftUI

/// Interactive demo view for previewing CRT shader effects.
///
/// Displays a colored background with CRT effects applied, along with
/// controls to switch between presets and adjust individual parameters.
///
/// ## Usage
///
/// ```swift
/// // In a preview or debug view:
/// CRTDemoView()
///
/// // With a custom starting preset:
/// CRTDemoView(initialPreset: .authentic)
/// ```
@available(iOS 17.0, macOS 14.0, *)
public struct CRTDemoView: View {

    // MARK: - Preset Enum

    /// Available CRT presets for the picker.
    public enum Preset: String, CaseIterable, Identifiable {
        case disabled = "Disabled"
        case subtle = "Subtle"
        case authentic = "Authentic"
        case performance = "Performance"
        case lowBrightness = "Low Brightness"
        case highBrightness = "High Brightness"
        case textOnly = "Text Only"

        public var id: String { rawValue }

        var config: CRTConfig {
            switch self {
            case .disabled: return .disabled
            case .subtle: return .subtle
            case .authentic: return .authentic
            case .performance: return .performance
            case .lowBrightness: return .lowBrightness
            case .highBrightness: return .highBrightness
            case .textOnly: return .textOnly
            }
        }
    }

    // MARK: - Nibble Level Colors (HSB values from Bit Quiz 16)

    /// Nibble level background: H=209, S=100%, B=36% (dark blue)
    public static let nibbleBackground = Color(hue: 209/360, saturation: 1.0, brightness: 0.36)
    /// Nibble level accent: H=29, S=100%, B=100% (orange)
    public static let nibbleAccent = Color(hue: 29/360, saturation: 1.0, brightness: 1.0)
    /// Nibble level primary: H=29, S=44%, B=100%
    public static let nibblePrimary = Color(hue: 29/360, saturation: 0.44, brightness: 1.0)
    /// Nibble level secondary: H=209, S=49%, B=80%
    public static let nibbleSecondary = Color(hue: 209/360, saturation: 0.49, brightness: 0.80)

    // MARK: - State

    @State private var selectedPreset: Preset
    @State private var config: CRTConfig
    @State private var backgroundColor: Color
    @State private var showControls: Bool = true

    // MARK: - Initializer

    /// Creates a CRT demo view.
    /// - Parameters:
    ///   - initialPreset: The preset to start with (default: .authentic)
    ///   - backgroundColor: The background color to apply effects to (default: Nibble level dark blue)
    public init(
        initialPreset: Preset = .authentic,
        backgroundColor: Color = nibbleBackground
    ) {
        _selectedPreset = State(initialValue: initialPreset)
        _config = State(initialValue: initialPreset.config)
        _backgroundColor = State(initialValue: backgroundColor)
    }

    // MARK: - Body

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background with CRT effects
                backgroundColor
                    .ignoresSafeArea()
                    .crtEffect(config: config, size: geometry.size)

                // Controls overlay
                if showControls {
                    controlsOverlay
                }
            }
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showControls.toggle()
                }
            }
        }
    }

    // MARK: - Controls Overlay

    private var controlsOverlay: some View {
        VStack {
            Spacer()

            VStack(spacing: 16) {
                // Header
                Text("CRT Effects Demo")
                    .font(.headline)
                    .foregroundStyle(Self.nibbleAccent)

                // Preset picker
                HStack {
                    Text("Preset:")
                        .foregroundStyle(.white.opacity(0.8))
                    Picker("Preset", selection: $selectedPreset) {
                        ForEach(Preset.allCases) { preset in
                            Text(preset.rawValue).tag(preset)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.white)
                    .onChange(of: selectedPreset) { _, newValue in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            config = newValue.config
                        }
                    }
                }

                Divider().background(.white.opacity(0.3))

                // Scanline controls
                VStack(alignment: .leading, spacing: 12) {
                    Text("Scanlines")
                        .font(.subheadline.bold())
                        .foregroundStyle(Self.nibbleAccent)

                    Toggle("Enabled", isOn: $config.scanlinesEnabled)
                        .tint(Self.nibbleAccent)

                    parameterSlider(
                        label: "Spacing",
                        value: Binding(
                            get: { Double(config.scanlineSpacing) },
                            set: { config.scanlineSpacing = Float($0) }
                        ),
                        range: 1...8,
                        format: "%.0f px"
                    )

                    parameterSlider(
                        label: "Intensity",
                        value: Binding(
                            get: { Double(config.scanlineIntensity) },
                            set: { config.scanlineIntensity = Float($0) }
                        ),
                        range: 0...0.5,
                        format: "%.2f"
                    )
                }

                Divider().background(.white.opacity(0.3))

                // Other effect toggles
                VStack(alignment: .leading, spacing: 8) {
                    Text("Other Effects")
                        .font(.subheadline.bold())
                        .foregroundStyle(Self.nibbleAccent)

                    Toggle("Barrel Distortion", isOn: $config.barrelEnabled)
                        .tint(Self.nibbleAccent)
                    Toggle("Vignette", isOn: $config.vignetteEnabled)
                        .tint(Self.nibbleAccent)
                    Toggle("Phosphor Glow", isOn: $config.glowEnabled)
                        .tint(Self.nibbleAccent)
                }

                Divider().background(.white.opacity(0.3))

                // Current values display
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Config")
                        .font(.subheadline.bold())
                        .foregroundStyle(Self.nibbleAccent)
                    Text("scanlineSpacing: \(config.scanlineSpacing, specifier: "%.1f")")
                        .font(.caption.monospaced())
                        .foregroundStyle(.white.opacity(0.7))
                    Text("scanlineIntensity: \(config.scanlineIntensity, specifier: "%.3f")")
                        .font(.caption.monospaced())
                        .foregroundStyle(.white.opacity(0.7))
                }

                Text("Tap background to hide controls")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(20)
            .background(.ultraThinMaterial.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding()
        }
        .foregroundStyle(.white)
    }

    // MARK: - Parameter Slider

    private func parameterSlider(
        label: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        format: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .foregroundStyle(.white.opacity(0.8))
                Spacer()
                Text(String(format: format, value.wrappedValue))
                    .font(.caption.monospaced())
                    .foregroundStyle(.white.opacity(0.6))
            }
            Slider(value: value, in: range)
                .tint(Self.nibbleAccent)
        }
    }
}

// MARK: - Previews

@available(iOS 17.0, macOS 14.0, *)
#Preview("CRT Demo - Nibble Theme") {
    CRTDemoView()
}

@available(iOS 17.0, macOS 14.0, *)
#Preview("CRT Demo - Subtle Preset") {
    CRTDemoView(initialPreset: .subtle)
}

@available(iOS 17.0, macOS 14.0, *)
#Preview("CRT Demo - Gray Background") {
    CRTDemoView(initialPreset: .authentic, backgroundColor: Color(white: 0.35))
}
