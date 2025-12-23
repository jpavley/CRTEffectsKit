# CRTEffectsKit

GPU-accelerated CRT monitor visual effects for SwiftUI.

## Overview

CRTEffectsKit provides Metal shader-based effects that simulate the look of vintage CRT monitors. Perfect for retro-styled games, terminal emulators, or any app that wants an authentic cathode ray tube aesthetic.

## Requirements

- iOS 17.0+ / macOS 14.0+ / visionOS 1.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add CRTEffectsKit to your project using Xcode:

1. File > Add Package Dependencies...
2. Enter the repository URL or local path
3. Select the version/branch you want to use

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(path: "../CRTEffectsKit")
]
```

## Usage

### Basic Usage

```swift
import SwiftUI
import CRTEffectsKit

struct ContentView: View {
    var body: some View {
        GeometryReader { geometry in
            YourGameView()
                .crtEffect(config: .authentic, size: geometry.size)
        }
    }
}
```

### Available Presets

| Preset | Description |
|--------|-------------|
| `.disabled` | All effects off |
| `.subtle` | Light retro feel - good starting point |
| `.authentic` | Full CRT experience with all effects |
| `.performance` | No glow/barrel, optimized for battery |
| `.lowBrightness` | For dark/indoor conditions |
| `.highBrightness` | For bright/outdoor conditions |

### Custom Configuration

```swift
var custom = CRTConfig.subtle
custom.scanlineIntensity = 0.2
custom.barrelIntensity = 0.1

view.crtEffect(config: custom, size: geometry.size)
```

### Animated Scanlines

Use `ScanlineFlickerManager` for realistic scanline animation:

```swift
@StateObject private var flickerManager = ScanlineFlickerManager(config: .subtle)

var body: some View {
    GeometryReader { geometry in
        YourView()
            .crtEffect(
                config: .authentic,
                size: geometry.size,
                scanlineIntensity: flickerManager.currentIntensity
            )
            .onAppear { flickerManager.startFlicker() }
            .onDisappear { flickerManager.stopFlicker() }
    }
}
```

Flicker presets: `.disabled`, `.subtle`, `.moderate`, `.unstable`, `.damaged`

## Effects

All effects are GPU-accelerated using Metal shaders:

- **Barrel Distortion** - Curves the screen like a CRT tube
- **Vignette** - Darkens edges with brighter center
- **Scanlines** - Horizontal line pattern simulating electron beam scanning
- **Phosphor Glow** - Bloom effect around bright pixels
- **Rounded Corners** - Clips to rounded rectangle shape

## Configuration Properties

### CRTConfig

| Property | Type | Range | Description |
|----------|------|-------|-------------|
| `enabled` | Bool | - | Master toggle for all effects |
| `barrelEnabled` | Bool | - | Enable barrel distortion |
| `barrelIntensity` | Float | 0.0-0.5 | Distortion strength |
| `vignetteEnabled` | Bool | - | Enable vignette effect |
| `vignetteIntensity` | Float | 0.0-1.0 | Edge darkening |
| `vignetteRadius` | Float | 0.5-1.5 | Falloff start point |
| `scanlinesEnabled` | Bool | - | Enable scanlines |
| `scanlineSpacing` | Float | 2-6 | Pixels between lines |
| `scanlineIntensity` | Float | 0.0-0.5 | Line darkness |
| `glowEnabled` | Bool | - | Enable phosphor glow |
| `glowIntensity` | Float | 0.0-1.0 | Glow strength |
| `cornerRadius` | CGFloat | - | Screen corner radius |
| `screenInset` | CGFloat | - | Edge inset for clean clipping |

## Performance Notes

- The **phosphor glow** effect is the most expensive (samples neighboring pixels)
- Use `.performance` preset for battery-conscious applications
- Disable barrel distortion if you notice frame drops on older devices

## License

MIT License - see LICENSE file for details.
