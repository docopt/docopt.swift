//
//  Pattern.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 3/1/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Foundation

typealias MatchResult = (match: Bool, left: [LeafPattern], collected: [LeafPattern])

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

    internal func flat() -> Array<Pattern> {
        return flat(LeafPattern)
    }

    internal func flat<T: Pattern>(_: T.Type) -> Array<Pattern> {
        return []
    }
}

internal func ==(lhs: Pattern, rhs: Pattern) -> Bool {
    if lhs is BranchPattern && rhs is BranchPattern {
        return lhs as! BranchPattern == rhs as! BranchPattern
    }
    if lhs is LeafPattern && rhs is LeafPattern {
        return lhs as! LeafPattern == rhs as! LeafPattern
    }
    return lhs === rhs // Pattern is abstract and shouldn't be instantiated :)
}

internal func ==(lhs: MatchResult, rhs: MatchResult) -> Bool {
    return lhs.match == rhs.match
        && lhs.left == rhs.left
        && lhs.collected == rhs.collected
}
