//
//  DocoptTestCasesTests.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 3/4/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import XCTest
@testable import Docopt

class DocoptTestCasesTests: XCTestCase {
    override func setUp() {
        DocoptError.test = true
    }

    func testTestCasesFileExists() {
        let fileManager: FileManager = FileManager.default
        let filePath: String? = fixturesFilePath()
        XCTAssertNotNil(filePath, "Fixtures file testcases.docopt does not exist in testing bundle")
        if let filePath = filePath {
            let exists: Bool = fileManager.fileExists(atPath: filePath)
            XCTAssertTrue(exists, "Fixtures file testcases.docopt does not exist in testing bundle")
        }
    }
    
    func testFixturesFileCanBeOpened() {
        XCTAssertNotEqual(fixturesFileContents(), "", "Could not read fixtures file")
    }
    
    func testTestCases() {
        let rawTestCases = fixturesFileContents()
        let parser = DocoptTestCaseParser(rawTestCases)
        
        for testCase in parser.testCases {
            let expectedOutput: AnyObject = testCase.expectedOutput
            var result: AnyObject = "user-error" as AnyObject
            let opt = Docopt(testCase.usage, argv: testCase.arguments)
            if DocoptError.errorMessage == nil {
                result = opt.result as AnyObject
            } else {
                DocoptError.errorMessage = nil
            }

            if let expectedDictionary = expectedOutput as? NSDictionary,
               let resultDictionary = result as? NSDictionary {
                if resultDictionary != expectedDictionary
                {
                    XCTAssert(false,
                    "Test \(testCase.name) failed. Expected:\n\(expectedDictionary)\n\n, got: \(resultDictionary)\n\n")
                }
            } else if let expectedString = expectedOutput as? String,
                      let resultString = result as? String {
                XCTAssertTrue(resultString == expectedString,
                    "Test \(testCase.name) failed. Expected:\n\(expectedString)\n\n, got: \(resultString)\n\n")
            } else {
                XCTFail("Test \(testCase.name) failed. Expected:\n\(expectedOutput)\n\n, got: \(result)\n\n\(testCase.usage)\n\(String(describing: testCase.arguments))\n\n")
            }
        }
    }
    
    private func fixturesFilePath() -> String? {
        let testBundle: Bundle = Bundle(for: type(of: self))
        guard let path = testBundle.path(forResource: "testcases", ofType: "docopt") else {
            // SwiftPM currently doesn't support bundles, so if the tests are run with it,
            // we'll fail to find the bundle path here.
            // As a temporary workaround, we can fall back on a relative path. This is fragile
            // as it relies on the assumption that we know where SwiftPM will put the
            // executable, and where the testcases file lives relative to it, but it's
            // better than just disabling all the tests...
            let url = testBundle.bundleURL.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("DocoptTests").appendingPathComponent("testcases.docopt")
            return url.path
        }
        
        return path
    }
    
    private func fixturesFileContents() -> String {
        if let filePath = self.fixturesFilePath() {
            let fileContents = try! String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
            return fileContents
        }
        return ""
    }
}
