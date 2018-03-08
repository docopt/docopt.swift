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
            let expectedOutput: Any = testCase.expectedOutput
            var result: Any = "user-error"
            let opt = Docopt(testCase.usage, argv: testCase.arguments)
            if DocoptError.errorMessage == nil {
                result = opt.result
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

    private func fallbackFilePath(from exeURL : URL) -> String? {
        // SwiftPM currently doesn't support building bundles, and Linux doesn't support
        // them at all, so if the tests are run with SwiftPM or on Linux,
        // we'll fail to find the bundle path here.
        // As a temporary workaround, we can fall back on a relative path from the executable.
        // This is fragile as it relies on the assumption that we know where SwiftPM will
        // put it, and where the testcases file lives relative to it, but it's
        // better than just disabling all the tests...
        let url = exeURL.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("Tests/DocoptTests/testcases.docopt")
        print(url.path)
        return url.path
    }

    private func fixturesFilePath() -> String? {
        #if os(Linux)
            return fallbackFilePath(from: URL(fileURLWithPath: CommandLine.arguments[0]))
        #else
        let testBundle: Bundle = Bundle(for: type(of: self))
        guard let path = testBundle.path(forResource: "testcases", ofType: "docopt") else {
            return fallbackFilePath(from: testBundle.bundleURL)
        }
        return path
        #endif
    }

    private func fixturesFileContents() -> String {
        if let filePath = self.fixturesFilePath() {
            let fileContents = try! String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
            return fileContents
        }
        return ""
    }

    static var allTests = [
        ("testTestCases", testTestCases),
    ]
}
