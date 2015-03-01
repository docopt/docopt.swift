//
//  DocoptTests.swift
//  docoptTests
//
//  Created by Pavel S. Mazurin on 2/28/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Cocoa
import XCTest

class DocoptTests: XCTestCase {
    
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
    
//    func testTestCases() {
//        var rawTestCases = fixturesFileContents();
//        var parser: DocoptTestCaseParser = DocoptTestCaseParser(stringOfTestCases: rawTestCases!)
//        
//        for testCase in parser.testCases {
//            let docopt: Docopt = Docopt(doc: testCase.usage, argv: testCase.arguments)
//            let result: AnyObject = docopt.result
//            let expectedOutput: AnyObject = testCase.expectedOutput
//            switch expectedOutput {
//            case let expectedOutput as NSDictionary:
//                if let result = result as? NSDictionary {
//                    XCTAssertTrue(result == expectedOutput, "Test \(testCase.name) failed");
//                } else {
////                    XCTFail("Test \(testCase.name) failed. Unexpected result type: \(result.dynamicType). Expected: \(expectedOutput.dynamicType)")
//                }
//                
//            case let expectedOutput as String:
//                if let result = result as? String {
//                    XCTAssertTrue(result == expectedOutput, "Test \(testCase.name) failed");
//                } else {
//                    XCTFail("Test \(testCase.name) failed. Unexpected result type: \(result.dynamicType). Expected: \(expectedOutput.dynamicType)")
//                }
//            default:
//                XCTFail("Test \(testCase.name) failed. Unexpected result type: \(result.dynamicType). Expected: \(expectedOutput.dynamicType)")
//            }
//        }
//    }

    func testParseDefaults() {
        let section = "options:\n\t-a        Add\n\t-r        Remote\n\t-m <msg>  Message"
        let options = Docopt.parseDefaults(section)
        var expected = Array<Option>()
        expected += [Option("-a")]
        expected += [Option("-r")]
        expected += [Option("-m", argCount: 1)]
        XCTAssertEqual(options, expected)
    }
    
    func testParseSection() {
        let usage = "usage: this\nusage:hai\nusage: this that\nusage: foo\n       bar\nPROGRAM USAGE:\n foo\n bar\nusage:\n\ttoo\n\ttar\nUsage: eggs spam\nBAZZ\nusage: pit stop"
        XCTAssertEqual(Docopt.parseSection("usage:", source: "foo bar fizz buzz"), [])
        XCTAssertEqual(Docopt.parseSection("usage:", source: "usage: prog"), ["usage: prog"])
        XCTAssertEqual(Docopt.parseSection("usage:", source: "usage: -x\n -y"), ["usage: -x\n -y"])
        XCTAssertEqual(Docopt.parseSection("usage:", source: usage), [
            "usage: this",
            "usage:hai",
            "usage: this that",
            "usage: foo\n       bar",
            "PROGRAM USAGE:\n foo\n bar",
            "usage:\n\ttoo\n\ttar",
            "Usage: eggs spam",
            "usage: pit stop",
            ])
    }
    
    func testFormalUsage() {
        let doc = "\nUsage: prog [-hv] ARG\n        prog N M\n\n        prog is a program."
        let usage = Docopt.parseSection("usage:", source: doc)[0]
        let formalUsage = Docopt.formalUsage(usage)
        
        XCTAssertEqual(usage, "Usage: prog [-hv] ARG\n        prog N M")
        XCTAssertEqual(formalUsage, "( [-hv] ARG ) | ( N M )")
    }
    
    func testParseArgv() {
        var o = [Option("-h"), Option("-v", long: "--verbose"), Option("-f", long:"--file", argCount: 1)]
        var TS = {(s: String) in return Tokens(s) }
        
        XCTAssertEqual(TS(""), Tokens([]))
    }
    
    
    func testParsePattern() {
        var o = [Option("-h"), Option("-v", long: "--verbose"), Option("-f", long:"--file", argCount: 1)]
        XCTAssertEqual(Docopt.parsePattern("[ -h ]", options: o), Required(Optional(Option("-h"))))
        XCTAssertEqual(Docopt.parsePattern("[ ARG ... ]", options: o), Required(Optional(OneOrMore(Argument("ARG")))))
        XCTAssertEqual(Docopt.parsePattern("[ -h | -v ]", options: o), Required(Optional(Either([Option("-h"), Option("-v", long: "--verbose")]))))
        XCTAssertEqual(Docopt.parsePattern("( -h | -v [ --file <f> ] )", options: o),
            Required(Required(
                Either([Option("-h"),
                    Required([Option("-v", long: "--verbose"),
                        Optional(Option("-f", long: "--file", argCount: 1))])]))))
        XCTAssertEqual(Docopt.parsePattern("(-h|-v[--file=<f>]N...)", options: o),
            Required(Required(Either([Option("-h"),
                Required([Option("-v", long: "--verbose"),
                    Optional(Option("-f", long: "--file", argCount: 1)),
                    OneOrMore(Argument("N"))])]))))
        XCTAssertEqual(Docopt.parsePattern("(N [M | (K | L)] | O P)", options: []),
            Required(Required(Either([
                Required([Argument("N"),
                    Optional(Either([Argument("M"),
                        Required(Either([Argument("K"),
                            Argument("L")]))]))]),
                Required([Argument("O"), Argument("P")])]))))
        XCTAssertEqual(Docopt.parsePattern("[ -h ] [N]", options: o),
            Required([Optional(Option("-h")),
                Optional(Argument("N"))]))
        XCTAssertEqual(Docopt.parsePattern("[options]", options: o),
            Required(Optional(OptionsShortcut([]))))
        XCTAssertEqual(Docopt.parsePattern("[options] A", options: o),
            Required([Optional(OptionsShortcut([])),
                Argument("A")]))
        XCTAssertEqual(Docopt.parsePattern("-v [options]", options: o),
            Required([Option("-v", long: "--verbose"),
                Optional(OptionsShortcut([]))]))
        XCTAssertEqual(Docopt.parsePattern("ADD", options: o), Required(Argument("ADD")))
        XCTAssertEqual(Docopt.parsePattern("<add>", options: o), Required(Argument("<add>")))
        XCTAssertEqual(Docopt.parsePattern("add", options: o), Required(Command("add")))
    }
    
    private func fixturesFilePath() -> String? {
        let testBundle: NSBundle = NSBundle(forClass: self.dynamicType)
        return testBundle.pathForResource("testcases", ofType: "docopt")
    }
    
    private func fixturesFileContents() -> String? {
        if let filePath = self.fixturesFilePath() {
            let fileContents = String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding, error: nil)
            return fileContents
        }
        return nil;
    }
}
