//
//  DocoptTestCase.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 2/28/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Foundation

public class DocoptTestCase {
    public var name: String = ""
    public var usage: String = ""

    public let programName: String
    public let arguments: [String]?
    public let expectedOutput: Any

    public init(_ programName: String, arguments: [String]?, expectedOutput: Any) {
        self.programName = programName
        self.arguments = arguments
        self.expectedOutput = expectedOutput
    }
}
