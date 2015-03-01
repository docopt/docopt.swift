//
//  BranchPattern.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 3/1/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Foundation

internal class BranchPattern : Pattern, Equatable {
    var children: Array<Pattern>
    override internal var description: String {
        get {
            return "BranchPattern(\(children))"
        }
    }

    internal convenience init(_ child: Pattern) {
        self.init([child])
    }

    internal init(_ children: Array<Pattern>) {
        self.children = children
    }
}

internal func ==(lhs: BranchPattern, rhs: BranchPattern) -> Bool {
    return lhs.children == rhs.children
}