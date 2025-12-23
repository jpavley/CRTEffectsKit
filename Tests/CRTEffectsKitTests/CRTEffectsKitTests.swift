//
//  CRTEffectsKitTests.swift
//  CRTEffectsKit
//
//  Created by Claude Code on 12/23/24.
//

import XCTest
@testable import CRTEffectsKit

final class CRTEffectsKitTests: XCTestCase {

    func testCRTConfigPresets() {
        // Verify presets have expected enabled states
        XCTAssertFalse(CRTConfig.disabled.enabled)
        XCTAssertTrue(CRTConfig.subtle.enabled)
        XCTAssertTrue(CRTConfig.authentic.enabled)
        XCTAssertTrue(CRTConfig.performance.enabled)
        XCTAssertTrue(CRTConfig.lowBrightness.enabled)
        XCTAssertTrue(CRTConfig.highBrightness.enabled)
    }

    func testCRTConfigAuthenticHasAllEffects() {
        let config = CRTConfig.authentic
        XCTAssertTrue(config.barrelEnabled)
        XCTAssertTrue(config.vignetteEnabled)
        XCTAssertTrue(config.scanlinesEnabled)
        XCTAssertTrue(config.glowEnabled)
    }

    func testCRTConfigPerformanceOptimized() {
        let config = CRTConfig.performance
        XCTAssertFalse(config.barrelEnabled)
        XCTAssertFalse(config.glowEnabled)
    }

    func testScanlineFlickerConfigPresets() {
        XCTAssertFalse(ScanlineFlickerConfig.disabled.enabled)
        XCTAssertTrue(ScanlineFlickerConfig.subtle.enabled)
        XCTAssertTrue(ScanlineFlickerConfig.moderate.enabled)
        XCTAssertTrue(ScanlineFlickerConfig.unstable.enabled)
        XCTAssertTrue(ScanlineFlickerConfig.damaged.enabled)
    }
}
