//
//  DocoptTestCasesTests.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 3/4/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Cocoa
import XCTest

class DocoptTestCasesTests: XCTestCase {
    func testTestCasesFileExists() {
        let fileManager: NSFileManager = NSFileManager.defaultManager()
        let filePath: String? = fixturesFilePath()
        XCTAssertNotNil(filePath, "Fixtures file testcases.docopt does not exist in testing bundle")
        if let filePath = filePath {
            let exists: Bool = fileManager.fileExistsAtPath(filePath)
            XCTAssertTrue(exists, "Fixtures file testcases.docopt does not exist in testing bundle")
        }
    }
    
    func testFixturesFileCanBeOpened() {
        XCTAssertNotNil(fixturesFileContents(), "Could not read fixtures file")
    }
    
    func testTestCases() {
        var rawTestCases = fixturesFileContents()
        var parser = DocoptTestCaseParser(rawTestCases)
        
        for testCase in parser.testCases {
            var result: AnyObject = "user-error"
            var capture = NMBExceptionCapture(handler: nil, finally: nil)
            capture.tryBlock {
                result = Docopt(testCase.usage, argv: testCase.arguments).result
            }
            
            let expectedOutput: AnyObject = testCase.expectedOutput
            switch expectedOutput {
            case let expectedOutput as NSDictionary:
                if let result = result as? NSDictionary {
                    XCTAssertTrue(result == expectedOutput, "Test \(testCase.name) failed. Expected:\n\(expectedOutput)\n\n, got: \(result)\n\n")
                } else {
                    XCTFail("Test \(testCase.name) failed. Unexpected result type: \(result.dynamicType). Expected: \(expectedOutput.dynamicType)")
                }
            case let expectedOutput as String:
                if let result = result as? String {
                    XCTAssertTrue(result == expectedOutput, "Test \(testCase.name) failed. Expected:\n\(expectedOutput)\n\n, got: \(result)\n\n")
                } else {
                    XCTFail("Test \(testCase.name) failed. Unexpected result type: \(result.dynamicType). Expected: \(expectedOutput.dynamicType)")
                }
            default:
                XCTFail("Test \(testCase.name) failed. Unexpected result type: \(result.dynamicType). Expected: \(expectedOutput.dynamicType)")
            }
        }
    }
    
    private func fixturesFilePath() -> String? {
        let testBundle: NSBundle = NSBundle(forClass: self.dynamicType)
        return testBundle.pathForResource("testcases", ofType: "docopt")
    }
    
    private func fixturesFileContents() -> String {
        if let filePath = self.fixturesFilePath() {
            let fileContents = String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding, error: nil)
            return fileContents!
        }
        return ""
    }
}