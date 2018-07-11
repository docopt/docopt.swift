import XCTest
@testable import DocoptTests

XCTMain([
    testCase(DocoptTestCasesTests.allTests),
    testCase(DocoptTests.allTests),
    testCase(ValueMatchingTests.allTests)
])
