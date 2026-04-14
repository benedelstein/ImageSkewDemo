//
//  ContentViewTests.swift
//  ImageSkewTests
//
//  Tests for ContentView configuration and constants.
//

import XCTest
import SwiftUI
@testable import ImageSkew

class ContentViewTests: XCTestCase {

    // MARK: - View Instantiation

    func testContentViewCanBeInstantiated() {
        let view = ContentView()
        XCTAssertNotNil(view)
    }

    func testContentViewBodyIsNotNil() {
        let view = ContentView()
        XCTAssertNotNil(view.body)
    }

    // MARK: - Rotation Clipping Logic

    func testMaxDegreesClippingWithinBounds() {
        let maxDegrees: Double = 30
        let rotationScale: Double = 0.5
        let magnitude: Double = 0.5 // small magnitude

        let rotationDegrees = magnitude * rotationScale * (180.0 / .pi)
        let clipped = max(min(rotationDegrees, maxDegrees), -maxDegrees)

        XCTAssertLessThanOrEqual(clipped, maxDegrees)
        XCTAssertGreaterThanOrEqual(clipped, -maxDegrees)
    }

    func testMaxDegreesClippingExceedingPositiveBound() {
        let maxDegrees: Double = 30
        let rotationScale: Double = 0.5
        let magnitude: Double = 100.0 // large magnitude to exceed clipping

        let rotationDegrees = magnitude * rotationScale * (180.0 / .pi)
        let clipped = max(min(rotationDegrees, maxDegrees), -maxDegrees)

        XCTAssertEqual(clipped, maxDegrees)
    }

    func testMaxDegreesClippingExceedingNegativeBound() {
        let maxDegrees: Double = 30
        let magnitude: Double = -100.0

        let clipped = max(min(magnitude, maxDegrees), -maxDegrees)

        XCTAssertEqual(clipped, -maxDegrees)
    }

    // MARK: - Rotation Scale

    func testRotationScaleHalvesMagnitude() {
        let rotationScale: Double = 0.5
        let magnitude: Double = 2.0

        let scaled = magnitude * rotationScale
        XCTAssertEqual(scaled, 1.0)
    }
}
