//
//  Tokens.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 3/1/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Foundation

internal class Tokens: Equatable, CustomStringConvertible {
    fileprivate var tokensArray: [String]
    var error: DocoptError
    
    var description: String {
        get {
            return "Tokens:\(tokensArray.joined(separator: " "))"
        }
    }

    
    convenience init(_ source: String, error: DocoptError = DocoptExit()) {
        self.init(source.split(), error: error)
    }
    
    init(_ source: [String], error: DocoptError = DocoptExit() ) {
        tokensArray = source
        self.error = error
    }
    
    static func fromPattern(_ source: String) -> Tokens {
        let res = source.replacingOccurrences(of: "([\\[\\]\\(\\)\\|]|\\.\\.\\.)", with: " $1 ", options: .regularExpression)
        let result = res.split("\\s+|(\\S*<.*?>)").filter { !$0.isEmpty }
        return Tokens(result, error: DocoptLanguageError())
    }
    
    func current() -> String? {
        if tokensArray.isEmpty {
            return nil
        }
        
        return tokensArray[0]
    }
    
    func move() -> String? {
        if tokensArray.isEmpty {
            return nil
        }
        return tokensArray.remove(at: 0)
    }
}

func ==(lhs: Tokens, rhs: Tokens) -> Bool {
    return lhs.tokensArray == rhs.tokensArray
}
