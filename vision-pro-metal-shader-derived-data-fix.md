# Vision Pro Metal Shader Derived Data Fix

This document explains a recurring issue with Metal shader compilation errors when adding Apple Vision Pro support to projects that use CRTEffectsKit, and how to resolve it.

## The Problem

When adding "Apple Vision (Designed for iPad)" or native visionOS as a supported destination in Xcode, you may encounter a Metal shader compilation error:

```
CRTEffectsKit
Command CompileMetalFile failed with a nonzero exit code

.../CRTEffectsKit.build/Debug-iphonesimulator/CRTEffectsKit_CRTEffectsKit.build/Metal/CRTShader.dia:1:1
Could not read serialized diagnostics file: error("Failed to open diagnostics file")
```

## Root Cause

This error is **not** caused by shader incompatibility with visionOS. CRTEffectsKit's Metal shaders are fully compatible with all Apple platforms including visionOS.

The actual cause is **corrupted derived data**:

1. When you add a new platform destination (like Vision Pro), Xcode begins generating Metal shader compilation artifacts for multiple platforms
2. If this process is interrupted (switching files, Xcode indexing, destination changes mid-compile), the `.dia` diagnostics file can be left in a corrupted or incomplete state
3. Subsequent builds fail because they cannot read the corrupted diagnostics file
4. Xcode Previews are particularly susceptible because they use a separate JIT compilation pipeline with independent caching

### Why ".dia" Files?

The `.dia` (diagnostics archive) file stores compiler warnings and errors during Metal shader compilation. Metal creates this file at the start of compilation. If compilation is interrupted before the file is finalized, it becomes unreadable.

## The Fix

### Step 1: Delete Derived Data

From Terminal, run:

```bash
# Remove all derived data for your project
rm -rf ~/Library/Developer/Xcode/DerivedData/YOUR_PROJECT_NAME-*

# Example for Card Flip Animation:
rm -rf ~/Library/Developer/Xcode/DerivedData/Card_Flip_Animation-*
```

Or delete via Xcode:
1. **Xcode → Settings → Locations**
2. Click the arrow next to "Derived Data" path
3. Delete the folder for your project

### Step 2: Quit Xcode Completely

**This step is critical.** Xcode keeps Preview build state in memory even after derived data is deleted.

- Press **Cmd+Q** to fully quit Xcode
- Do not just close the window — the app must quit entirely
- Verify Xcode is not running in the Dock

### Step 3: Reopen and Rebuild

1. Reopen your project in Xcode
2. **Build first** (Cmd+B) before using Previews
3. Wait for the build to complete successfully
4. Then try Previews

### Step 4: If Error Persists (Nuclear Option)

If the error still occurs after the above steps:

```bash
# 1. Quit Xcode

# 2. Remove ALL derived data (affects all projects)
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# 3. Clear Xcode's preview-specific caches
rm -rf ~/Library/Caches/com.apple.dt.Xcode

# 4. Clear Swift Package Manager cache for the package
rm -rf ~/Developer/CRTEffectsKit/.build
rm -rf ~/Developer/CRTEffectsKit/.swiftpm

# 5. Reopen Xcode and rebuild
```

## Understanding "Designed for iPad" vs Native visionOS

| Mode | Description | Metal Shaders |
|------|-------------|---------------|
| **Designed for iPad** | Runs your iPad app in a compatibility window on Vision Pro | Uses iOS-compiled shaders in compatibility layer |
| **Native visionOS** | Full visionOS app with spatial features | Requires visionOS-compiled shaders |

CRTEffectsKit supports both modes:
- `Package.swift` declares `.visionOS(.v1)` platform support
- Metal shaders use standard APIs compatible with all platforms
- No platform-specific conditionals in shader code

## Prevention Tips

1. **Avoid switching destinations during builds** — Wait for builds/indexing to complete before changing the destination picker

2. **Clean before adding new platforms** — Before adding Vision Pro support, do a clean build (Cmd+Shift+K)

3. **Build before Previewing** — After any destination changes, run a full build (Cmd+B) before opening Previews

4. **Watch for indexing** — The progress bar at the top of Xcode shows indexing status. Wait for it to complete.

## Technical Details

### Affected Path Structure

The corrupted file is typically located at:
```
~/Library/Developer/Xcode/DerivedData/
  PROJECT_NAME-HASH/
    Build/Intermediates.noindex/
      Previews/iphonesimulator/        ← Preview-specific builds
        PROJECT_NAME/Intermediates.noindex/
          CRTEffectsKit.build/
            Debug-iphonesimulator/
              CRTEffectsKit_CRTEffectsKit.build/
                Metal/
                  CRTShader.dia        ← Corrupted diagnostics file
```

### Why Previews Are More Susceptible

Xcode Previews use a separate compilation pipeline:
- JIT (Just-In-Time) compilation for fast iteration
- Independent caching from main build
- In-memory state that persists even after deleting derived data
- Requires full Xcode restart to clear

## Version History

| Date | Issue | Resolution |
|------|-------|------------|
| Jan 2026 | CompileMetalFile error after adding Vision Pro destination | Derived data cleanup + Xcode restart |
| Jan 2026 | Same error recurred on second Vision Pro addition | Documented fix for future reference |

---

*This document is part of CRTEffectsKit. The shaders themselves are fully compatible with visionOS — this error is purely a build system caching issue.*
