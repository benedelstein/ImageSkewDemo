//
//  MotionManagerTests.swift
//  ImageSkewTests
//
//  Tests for MotionManager utility functions and state management.
//

import XCTest
@testable import ImageSkew

class MotionManagerTests: XCTestCase {

    var sut: MotionManager!

    override func setUp() {
        super.setUp()
        sut = MotionManager()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func testInitialXIsZero() {
        XCTAssertEqual(sut.x, 0.0)
    }

    func testInitialYIsZero() {
        XCTAssertEqual(sut.y, 0.0)
    }

    func testInitialZIsZero() {
        XCTAssertEqual(sut.z, 0.0)
    }

    func testInitialMagnitudeIsZero() {
        XCTAssertEqual(sut.magnitude, 0.0)
    }

    func testReferenceAttitudeIsNilInitially() {
        XCTAssertNil(sut.referenceAttitude)
    }

    // MARK: - degrees(_:)

    func testDegreesFromZeroRadians() {
        XCTAssertEqual(sut.degrees(0), 0.0, accuracy: 1e-10)
    }

    func testDegreesFromPiRadians() {
        XCTAssertEqual(sut.degrees(.pi), 180.0, accuracy: 1e-10)
    }

    func testDegreesFromHalfPiRadians() {
        XCTAssertEqual(sut.degrees(.pi / 2), 90.0, accuracy: 1e-10)
    }

    func testDegreesFromNegativePiRadians() {
        XCTAssertEqual(sut.degrees(-.pi), -180.0, accuracy: 1e-10)
    }

    func testDegreesFromTwoPiRadians() {
        XCTAssertEqual(sut.degrees(2 * .pi), 360.0, accuracy: 1e-10)
    }

    func testDegreesFromQuarterPiRadians() {
        XCTAssertEqual(sut.degrees(.pi / 4), 45.0, accuracy: 1e-10)
    }

    func testDegreesFromOneRadian() {
        let expected = 180.0 / .pi
        XCTAssertEqual(sut.degrees(1.0), expected, accuracy: 1e-10)
    }

    // MARK: - stopUpdates()

    func testStopUpdatesResetsXToZero() {
        sut.x = 1.5
        sut.stopUpdates()
        XCTAssertEqual(sut.x, 0.0)
    }

    func testStopUpdatesResetsYToZero() {
        sut.y = -2.3
        sut.stopUpdates()
        XCTAssertEqual(sut.y, 0.0)
    }

    func testStopUpdatesResetsZToZero() {
        sut.z = 0.8
        sut.stopUpdates()
        XCTAssertEqual(sut.z, 0.0)
    }

    func testStopUpdatesResetsMagnitudeToZero() {
        sut.magnitude = 3.14
        sut.stopUpdates()
        XCTAssertEqual(sut.magnitude, 0.0)
    }

    func testStopUpdatesResetsAllValues() {
        sut.x = 1.0
        sut.y = 2.0
        sut.z = 3.0
        sut.magnitude = 4.0
        sut.stopUpdates()
        XCTAssertEqual(sut.x, 0.0)
        XCTAssertEqual(sut.y, 0.0)
        XCTAssertEqual(sut.z, 0.0)
        XCTAssertEqual(sut.magnitude, 0.0)
    }
}
