//
//  BranchPattern.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 3/1/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Foundation

internal class BranchPattern : Pattern, Equatable {
    var children: [Pattern]
    override var description: String {
        get {
            return "BranchPattern(\(children))"
        }
    }

    convenience init(_ child: Pattern) {
        self.init([child])
    }

    init(_ children: [Pattern]) {
        self.children = children
    }
    
    override func fixIdentities(_ unq: [LeafPattern]? = nil) {
        var uniq: [LeafPattern] = unq ?? Array(Set(flat()))
        
        for var i = 0; i < count(children); i++ {
            let child = children[i]
            if let leafChild = child as? LeafPattern {
                assert(contains(uniq, leafChild))
                children[i] = uniq[find(uniq, leafChild)!]
            } else {
                child.fixIdentities(uniq)
            }
        }
    }
    
    override func flat<T: Pattern>(type: T.Type) -> [T] {
        if self.dynamicType === T.self {
            return [self as! T]
        }
        var result = [T]()
        for child in children {
            result += child.flat(T)
        }
        return result
    }
}

func ==(lhs: BranchPattern, rhs: BranchPattern) -> Bool {
    return lhs.children == rhs.children
}