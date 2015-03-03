//
//  DocoptError.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 3/1/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Foundation

internal class DocoptError {
    internal var message: String
    internal var name: String
    internal init (_ message: String, name: String) {
        self.message = message
        self.name = name
    }
    
    internal func raise(_ message: String? = nil) {
        var msg = (message ?? self.message).strip()
        NSException(
            name: NSInternalInconsistencyException,
            reason: msg,
            userInfo: nil).raise()
    }
}

internal class DocoptLanguageError: DocoptError {
    internal init (_ message: String = "Error in construction of usage-message by developer.") {
        super.init(message, name: "DocoptLanguageError")
    }
}

internal class DocoptExit: DocoptError {
    static var usage: String = ""
    internal init (_ message: String = "Exit in case user invoked program with incorrect arguments.") {
        super.init(message, name: "DocoptExit")
    }

    override internal func raise(_ message: String? = nil) {
        super.raise("\(message ?? self.message)\(DocoptExit.usage)")
    }
}