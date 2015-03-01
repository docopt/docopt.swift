//
//  DocoptError.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 3/1/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Foundation
import Darwin

internal class DocoptError {
    internal var message: String
    internal init (_ message: String) {
        self.message = message
    }
    
    internal func raise() {
        println("\(message)".strip())
        exit(0)
    }
}

internal class DocoptLanguageError: DocoptError {
    override internal init (_ message: String = "Error in construction of usage-message by developer.") {
        super.init(message)
    }
}

internal class DocoptExit: DocoptError {
    static var usage: String = ""
    override internal init (_ message: String = "Exit in case user invoked program with incorrect arguments.") {
        super.init(message)
    }

    override internal func raise() {
        println("\(message)\n\(DocoptExit.usage)".strip())
        exit(0)
    }
}