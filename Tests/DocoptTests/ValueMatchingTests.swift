//
//  ValueMatchingSwiftTests.swift
//  Docopt
//
//  Created by Sam Deane on 08/03/2018.
//

import XCTest

class ValueMatchingTests: XCTestCase {
    func testNumberNumber() {
        XCTAssertTrue(valuesMatch(1, 1))
        XCTAssertFalse(valuesMatch(1, 4))
    }
    func testNumberString() {
        XCTAssertTrue(valuesMatch(1, "1"))
        XCTAssertFalse(valuesMatch(1, "4"))
    }
    func testStringString() {
        XCTAssertTrue(valuesMatch("test", "test"))
        XCTAssertFalse(valuesMatch("test", "blah"))
    }
    func testBoolBool() {
        XCTAssertTrue(valuesMatch(false, false))
        XCTAssertFalse(valuesMatch(false, true))
    }
    func testArrays() {
        XCTAssertTrue(valuesMatch([10,20], ["10", "20"]))
        XCTAssertFalse(valuesMatch([10,20], [20,10]))
        XCTAssertFalse(valuesMatch([10,20], [10]))
        XCTAssertFalse(valuesMatch([10,20], 10))
    }
    func testDictionaries() {
        XCTAssertTrue(valuesMatch(["name" : "test", "x" : 10, "y" : "20", "check" : false], ["x" : "10", "y" : 20, "name" : "test", "check" : false]))
    }

    static var allTests = [
        ("testNumberNumber", testNumberNumber),
        ("testNumberString", testNumberString),
        ("testStringString", testStringString),
        ("testBoolBool", testBoolBool),
        ("testArrays", testArrays),
        ("testDictionaries", testDictionaries),
        ]

}

