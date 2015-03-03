//
//  DocoptTestCaseParser.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 2/28/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Foundation

public struct DocoptTestCaseParser {
    public var testCases: Array<DocoptTestCase>!
    
    public init(_ stringOfTestCases: String) {
        testCases = parse(stringOfTestCases)
    }
    
    private func parse(stringOfTestCases: String) -> Array<DocoptTestCase> {
        var fixturesWithCommentsStripped: String = removeComments(stringOfTestCases);
        var fixtures: Array<String> = parseFixtures(fixturesWithCommentsStripped)
        var testCases: Array<DocoptTestCase> = parseFixturesArray(fixtures)
        
        return testCases;
    }
    
    private func removeComments(string: String) -> String {
        var removeCommentsRegEx: NSRegularExpression? = NSRegularExpression(pattern: "(?m)#.*$", options: .allZeros, error: nil)
        if let removeCommentsRegEx = removeCommentsRegEx {
            let fullRange: NSRange = NSMakeRange(0, count(string));
            return removeCommentsRegEx.stringByReplacingMatchesInString(string, options: .allZeros, range: fullRange, withTemplate: "")
        }
        
        return string
    }
    
    private func parseFixtures(fixturesString: String) -> Array<String> {
        var fixtures: Array<String> = fixturesString.componentsSeparatedByString("r\"\"\"")
        return arrayByRemovingStringsContainingOnlyWhitespace(fixtures)
    }
    
    private func parseFixturesArray(fixtureStrings: Array<String>) -> Array<DocoptTestCase> {
        var allTestCases: Array<DocoptTestCase> = []
        let testBaseName: String = "Test"
        var testIndex: Int = 1
        for fixtureString in fixtureStrings {
            var newTestCases: Array<DocoptTestCase> = testCasesFromFixtureString(fixtureString)
            for testCase: DocoptTestCase in newTestCases {
                testCase.name = testBaseName + String(testIndex)
                testIndex++
            }
            
            allTestCases += newTestCases
        }
        
        return allTestCases
    }
    
    private func testCasesFromFixtureString(fixtureString: String) -> Array<DocoptTestCase> {
        var testCases: Array<DocoptTestCase> = []
        let fixtureComponents: Array<String> = fixtureString.componentsSeparatedByString("\"\"\"")
        assert(count(fixtureComponents) == 2, "Could not split fixture: \(fixtureString) into components")
        let usageDoc: String = fixtureComponents[0]
        let testInvocationString: String = fixtureComponents[1]
        
        let testInvocations: Array<String> = parseTestInvocations(testInvocationString)
        for testInvocation in testInvocations {
            let testCase: DocoptTestCase? = parseTestCase(testInvocation);
            if let testCase = testCase {
                testCase.usage = usageDoc
                testCases.append(testCase)
            }
        }
        
        return testCases
    }
    
    private func parseTestCase(invocationString: String) -> DocoptTestCase? {
        let trimmedTestInvocation: String = invocationString.strip();
        var testInvocationComponents: Array<String> = trimmedTestInvocation.componentsSeparatedByString("\n");
        assert(count(testInvocationComponents) >= 2, "Could not split test case: \(trimmedTestInvocation) into components");
        
        let input: String = testInvocationComponents[0]; // first line
        testInvocationComponents.removeAtIndex(0);
        let expectedOutput: String = "\n".join(testInvocationComponents); // all remaining lines
        
        var inputComponents: Array<String> = input.componentsSeparatedByString(" ");
        let programName: String = inputComponents[0]; // first part
        inputComponents.removeAtIndex(0);
        
        var error : NSError?;
        let jsonData: NSData? = expectedOutput.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        if jsonData == nil {
            NSLog("Error parsing \(expectedOutput) to JSON: \(error)")
            return nil
        }
        let expectedOutputJSON: AnyObject? = NSJSONSerialization.JSONObjectWithData(jsonData!, options: .AllowFragments, error: &error)
        if (expectedOutputJSON == nil) {
            NSLog("Error parsing \(expectedOutput) to JSON: \(error)")
            return nil
        }
        
        let testCase: DocoptTestCase = DocoptTestCase(programName, arguments: inputComponents, expectedOutput: expectedOutputJSON!)
        return testCase
    }
    
    private func parseTestInvocations(stringOfTestInvocations: String) -> Array<String> {
        let testInvocations: Array<String> = stringOfTestInvocations.componentsSeparatedByString("$ ")
        return arrayByRemovingStringsContainingOnlyWhitespace(testInvocations)
    }
    
    private func arrayByRemovingStringsContainingOnlyWhitespace(sourceArray: Array<String>) -> Array<String> {
        return sourceArray.filter({
            return !$0.strip().isEmpty
        })
    }
}