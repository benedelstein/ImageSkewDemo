//
//  MotionManagerTests.swift
//  ImageSkewTests
//
//  A BDD-style, property-based test suite with a lightweight
//  given/when/then DSL and randomized fuzz inputs.
//

import XCTest
@testable import ImageSkew

// MARK: - Micro BDD DSL

struct Given<T> {
    let subject: T
    func when<U>(_ action: (T) -> U) -> When<U> { When(result: action(subject)) }
    func when(_ action: (T) -> Void) -> When<T> { action(subject); return When(result: subject) }
}

struct When<T> {
    let result: T
    func then(_ assertion: (T) -> Void) { assertion(result) }
}

func given<T>(_ subject: T) -> Given<T> { Given(subject: subject) }

// MARK: - Random Helpers

func randomRadians(count: Int = 50) -> [Double] {
    (0..<count).map { _ in Double.random(in: -10 * .pi ... 10 * .pi) }
}

func randomMagnitudes(count: Int = 50) -> [Double] {
    (0..<count).map { _ in Double.random(in: -1000...1000) }
}

// MARK: - MotionManager Tests

class MotionManagerBDDTests: XCTestCase {

    // MARK: Birth of a MotionManager

    func testNewbornManagerIsAtRest() {
        given(MotionManager())
            .when { $0 }
            .then { manager in
                XCTAssertEqual(manager.x, 0, "x should be still")
                XCTAssertEqual(manager.y, 0, "y should be still")
                XCTAssertEqual(manager.z, 0, "z should be still")
                XCTAssertEqual(manager.magnitude, 0, "magnitude should be zero")
                XCTAssertNil(manager.referenceAttitude, "no reference yet")
            }
    }

    // MARK: Degrees Conversion — Known Values

    func testDegreesIdentityTable() {
        let table: [(radians: Double, degrees: Double)] = [
            (0,            0),
            (.pi / 6,      30),
            (.pi / 4,      45),
            (.pi / 3,      60),
            (.pi / 2,      90),
            (.pi,          180),
            (3 * .pi / 2,  270),
            (2 * .pi,      360),
            (-.pi,         -180),
            (-.pi / 2,     -90),
        ]

        let manager = MotionManager()
        for entry in table {
            given(manager)
                .when { $0.degrees(entry.radians) }
                .then { result in
                    XCTAssertEqual(result, entry.degrees, accuracy: 1e-10,
                                   "\(entry.radians) rad should be \(entry.degrees)°")
                }
        }
    }

    // MARK: Degrees Conversion — Fuzz: Roundtrip Property

    func testDegreesRoundtripProperty() {
        // Property: degrees(radians) * pi / 180 == radians
        let manager = MotionManager()
        for rad in randomRadians() {
            given(manager)
                .when { $0.degrees(rad) }
                .then { deg in
                    let backToRad = deg * .pi / 180.0
                    XCTAssertEqual(backToRad, rad, accuracy: 1e-10,
                                   "roundtrip failed for \(rad)")
                }
        }
    }

    // MARK: Degrees Conversion — Fuzz: Linearity Property

    func testDegreesIsLinear() {
        // Property: degrees(a + b) == degrees(a) + degrees(b)
        let manager = MotionManager()
        for _ in 0..<50 {
            let a = Double.random(in: -100...100)
            let b = Double.random(in: -100...100)
            let sumDeg = manager.degrees(a + b)
            let degSum = manager.degrees(a) + manager.degrees(b)
            XCTAssertEqual(sumDeg, degSum, accuracy: 1e-9,
                           "linearity broken for a=\(a), b=\(b)")
        }
    }

    // MARK: Degrees Conversion — Fuzz: Scaling Property

    func testDegreesScalesWithConstant() {
        // Property: degrees(k * r) == k * degrees(r)
        let manager = MotionManager()
        for rad in randomRadians(count: 30) {
            let k = Double.random(in: -50...50)
            given(manager)
                .when { ($0.degrees(k * rad), k * $0.degrees(rad)) }
                .then { (scaled, expected) in
                    XCTAssertEqual(scaled, expected, accuracy: 1e-8,
                                   "scaling broken for k=\(k), rad=\(rad)")
                }
        }
    }

    // MARK: Degrees Conversion — Fuzz: Monotonicity

    func testDegreesIsMonotonic() {
        // Property: if a < b then degrees(a) < degrees(b)
        let manager = MotionManager()
        var values = randomRadians(count: 100)
        values.sort()
        for i in 0..<(values.count - 1) {
            XCTAssertLessThan(manager.degrees(values[i]),
                              manager.degrees(values[i + 1]),
                              "monotonicity violated at index \(i)")
        }
    }

    // MARK: Stop Updates — The Big Red Button

    func testStopUpdatesZeroesEverythingFromRandomState() {
        for _ in 0..<20 {
            given(MotionManager())
                .when { manager in
                    manager.x = Double.random(in: -999...999)
                    manager.y = Double.random(in: -999...999)
                    manager.z = Double.random(in: -999...999)
                    manager.magnitude = Double.random(in: 0...999)
                    manager.stopUpdates()
                }
                .then { manager in
                    XCTAssertEqual(manager.x, 0)
                    XCTAssertEqual(manager.y, 0)
                    XCTAssertEqual(manager.z, 0)
                    XCTAssertEqual(manager.magnitude, 0)
                }
        }
    }

    func testStopUpdatesIsIdempotent() {
        given(MotionManager())
            .when { manager in
                manager.x = 42
                for _ in 0..<100 { manager.stopUpdates() }
            }
            .then { manager in
                XCTAssertEqual(manager.x, 0, "still zero after 100 stops")
            }
    }
}
