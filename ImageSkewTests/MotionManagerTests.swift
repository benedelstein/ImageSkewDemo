//
//  MotionManagerTests.swift
//  ImageSkewTests
//

import Testing
@testable import ImageSkew

@Suite("MotionManager")
struct MotionManagerTests {

    // MARK: - Initial State

    @Suite("Initial State")
    struct InitialState {
        let manager = MotionManager()

        @Test("Published properties start at zero")
        func publishedPropertiesAreZero() {
            #expect(manager.x == 0.0)
            #expect(manager.y == 0.0)
            #expect(manager.z == 0.0)
            #expect(manager.magnitude == 0.0)
        }

        @Test("Reference attitude is nil before first motion update")
        func referenceAttitudeIsNil() {
            #expect(manager.referenceAttitude == nil)
        }
    }

    // MARK: - Degrees Conversion

    @Suite("Degrees Conversion")
    struct DegreesConversion {
        let manager = MotionManager()

        @Test("Common radian values convert correctly",
              arguments: [
                (0.0, 0.0),
                (Double.pi, 180.0),
                (Double.pi / 2, 90.0),
                (Double.pi / 4, 45.0),
                (2 * Double.pi, 360.0),
              ])
        func commonValues(radians: Double, expectedDegrees: Double) {
            let result = manager.degrees(radians)
            #expect(abs(result - expectedDegrees) < 1e-10)
        }

        @Test("Negative radians produce negative degrees")
        func negativeRadians() {
            let result = manager.degrees(-.pi)
            #expect(abs(result - (-180.0)) < 1e-10)
        }

        @Test("One radian equals 180/pi degrees")
        func oneRadian() {
            let expected = 180.0 / .pi
            let result = manager.degrees(1.0)
            #expect(abs(result - expected) < 1e-10)
        }
    }

    // MARK: - Stop Updates

    @Suite("Stop Updates")
    struct StopUpdates {

        @Test("Resets all published properties to zero")
        func resetsAllProperties() {
            let manager = MotionManager()
            manager.x = 1.5
            manager.y = -2.3
            manager.z = 0.8
            manager.magnitude = 3.14

            manager.stopUpdates()

            #expect(manager.x == 0.0)
            #expect(manager.y == 0.0)
            #expect(manager.z == 0.0)
            #expect(manager.magnitude == 0.0)
        }

        @Test("Is idempotent when called multiple times")
        func idempotent() {
            let manager = MotionManager()
            manager.x = 5.0
            manager.stopUpdates()
            manager.stopUpdates()

            #expect(manager.x == 0.0)
            #expect(manager.y == 0.0)
            #expect(manager.z == 0.0)
            #expect(manager.magnitude == 0.0)
        }
    }
}
