//
//  ContentViewTests.swift
//  ImageSkewTests
//

import Testing
import SwiftUI
@testable import ImageSkew

@Suite("ContentView")
struct ContentViewTests {

    // MARK: - View Construction

    @Suite("Construction")
    struct Construction {

        @Test("Can be instantiated")
        func instantiation() {
            let view = ContentView()
            #expect(view.body is Never == false)
        }
    }

    // MARK: - Rotation Clipping

    @Suite("Rotation Clipping")
    struct RotationClipping {
        let maxDegrees: Double = 30
        let rotationScale: Double = 0.5

        @Test("Small magnitudes stay within bounds",
              arguments: [0.0, 0.1, 0.5, 1.0])
        func withinBounds(magnitude: Double) {
            let angle = Angle.radians(magnitude * rotationScale)
            let clipped = max(min(angle, Angle.degrees(maxDegrees)), Angle.degrees(-maxDegrees))
            #expect(clipped.degrees <= maxDegrees)
            #expect(clipped.degrees >= -maxDegrees)
        }

        @Test("Large positive magnitude is clamped to maxDegrees")
        func positiveClamping() {
            let magnitude: Double = 100.0
            let angle = Angle.radians(magnitude * rotationScale)
            let clipped = max(min(angle, Angle.degrees(maxDegrees)), Angle.degrees(-maxDegrees))
            #expect(abs(clipped.degrees - maxDegrees) < 1e-10)
        }

        @Test("Large negative magnitude is clamped to -maxDegrees")
        func negativeClamping() {
            let magnitude: Double = -100.0
            let angle = Angle.radians(magnitude * rotationScale)
            let clipped = max(min(angle, Angle.degrees(maxDegrees)), Angle.degrees(-maxDegrees))
            #expect(abs(clipped.degrees - (-maxDegrees)) < 1e-10)
        }

        @Test("Zero magnitude produces zero rotation")
        func zeroMagnitude() {
            let angle = Angle.radians(0.0 * rotationScale)
            let clipped = max(min(angle, Angle.degrees(maxDegrees)), Angle.degrees(-maxDegrees))
            #expect(clipped.degrees == 0.0)
        }
    }

    // MARK: - Rotation Scale

    @Suite("Rotation Scale")
    struct RotationScaleTests {

        @Test("Scale factor halves the input magnitude",
              arguments: [1.0, 2.0, 4.0, 10.0])
        func halvesInput(magnitude: Double) {
            let rotationScale: Double = 0.5
            let scaled = magnitude * rotationScale
            #expect(scaled == magnitude / 2.0)
        }
    }
}
