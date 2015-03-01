//
//  LeafPattern.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 3/1/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Foundation

internal class LeafPattern : Pattern, Equatable {
    var name: String
    var value: String?
    override internal var description: String {
        get {
            return "LeafPattern(\(name), \(value))"
        }
    }
    
    internal init(_ name: String, value: String? = nil) {
        self.name = name
        self.value = value
    }
}

internal func ==(lhs: LeafPattern, rhs: LeafPattern) -> Bool {
    return lhs.name == rhs.name && lhs.value == rhs.value
}