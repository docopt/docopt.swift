//
//  Pattern.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 3/1/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Foundation

internal class Pattern: Equatable, Printable {
    internal func fix() -> Pattern {
        fixIdentities()
        fixRepeatingArguments()
        return self;
    }
    
    internal var description: String {
        get {
            return "Pattern"
        }
    }

    private func fixIdentities(uniq: Array<Pattern>? = nil) {
        if !(self is BranchPattern) {
            return
        }
        
        let children: Array<Pattern> = (self as! BranchPattern).children
        
        for child in children {
            
        }
    }
    
    private func fixRepeatingArguments() {
        
    }
}

internal func ==(lhs: Pattern, rhs: Pattern) -> Bool {
    if lhs is BranchPattern && rhs is BranchPattern {
        return lhs as! BranchPattern == rhs as! BranchPattern
    }
    if lhs is LeafPattern && rhs is LeafPattern {
        return lhs as! LeafPattern == rhs as! LeafPattern
    }
    return false // Pattern is abstract and shouldn't be instantiated :)
}
