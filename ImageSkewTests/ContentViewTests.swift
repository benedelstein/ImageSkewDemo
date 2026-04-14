//
//  ContentViewTests.swift
//  ImageSkewTests
//
//  Fuzz-driven tests for ContentView's rotation clamping logic,
//  using the same BDD DSL.
//

import XCTest
import SwiftUI
@testable import ImageSkew

// MARK: - Rotation Clamp (mirrors ContentView logic)

private func clampedRotation(magnitude: Double,
                              scale: Double = 0.5,
                              maxDeg: Double = 30) -> Angle {
    let raw = Angle.radians(magnitude * scale)
    return max(min(raw, Angle.degrees(maxDeg)), Angle.degrees(-maxDeg))
}

// MARK: - ContentView Tests

class ContentViewBDDTests: XCTestCase {

    // MARK: Construction

    func testContentViewExists() {
        given(ContentView())
            .when { $0 }
            .then { XCTAssertNotNil($0.body) }
    }

    // MARK: Clamping — Fuzz: Output Always In Bounds

    func testClampedRotationNeverExceedsBounds() {
        // Property: for ANY magnitude, output is in [-30°, 30°]
        for magnitude in randomMagnitudes(count: 200) {
            given(magnitude)
                .when { clampedRotation(magnitude: $0) }
                .then { angle in
                    XCTAssertLessThanOrEqual(angle.degrees, 30.0 + 1e-10,
                        "exceeded +30° for magnitude \(magnitude)")
                    XCTAssertGreaterThanOrEqual(angle.degrees, -30.0 - 1e-10,
                        "exceeded -30° for magnitude \(magnitude)")
                }
        }
    }

    // MARK: Clamping — Fuzz: Small Inputs Pass Through

    func testSmallMagnitudesAreNotClamped() {
        // Property: if |magnitude * scale| is small enough in radians,
        // it should equal the unclamped value
        for _ in 0..<100 {
            let magnitude = Double.random(in: -0.5...0.5) // small enough
            given(magnitude)
                .when { clampedRotation(magnitude: $0) }
                .then { angle in
                    let raw = Angle.radians(magnitude * 0.5)
                    XCTAssertEqual(angle.radians, raw.radians, accuracy: 1e-10,
                        "small magnitude \(magnitude) was unexpectedly clamped")
                }
        }
    }

    // MARK: Clamping — Fuzz: Symmetry

    func testClampingIsAntiSymmetric() {
        // Property: clamp(-m) == -clamp(m)
        for magnitude in randomMagnitudes(count: 100) {
            let pos = clampedRotation(magnitude: magnitude)
            let neg = clampedRotation(magnitude: -magnitude)
            XCTAssertEqual(pos.degrees, -neg.degrees, accuracy: 1e-10,
                "anti-symmetry broken for magnitude \(magnitude)")
        }
    }

    // MARK: Clamping — Fuzz: Monotonicity

    func testClampingIsMonotonic() {
        // Property: if a < b then clamp(a) <= clamp(b)
        var magnitudes = randomMagnitudes(count: 200)
        magnitudes.sort()
        for i in 0..<(magnitudes.count - 1) {
            let a = clampedRotation(magnitude: magnitudes[i])
            let b = clampedRotation(magnitude: magnitudes[i + 1])
            XCTAssertLessThanOrEqual(a.degrees, b.degrees + 1e-10,
                "monotonicity broken between \(magnitudes[i]) and \(magnitudes[i+1])")
        }
    }

    // MARK: Clamping — Edge Cases

    func testZeroMagnitudeGivesZeroRotation() {
        given(0.0)
            .when { clampedRotation(magnitude: $0) }
            .then { XCTAssertEqual($0.degrees, 0) }
    }

    func testExtremePositiveSaturatesAtMax() {
        given(Double.greatestFiniteMagnitude)
            .when { clampedRotation(magnitude: $0) }
            .then { XCTAssertEqual($0.degrees, 30, accuracy: 1e-10) }
    }

    func testExtremeNegativeSaturatesAtMin() {
        given(-Double.greatestFiniteMagnitude)
            .when { clampedRotation(magnitude: $0) }
            .then { XCTAssertEqual($0.degrees, -30, accuracy: 1e-10) }
    }
}
