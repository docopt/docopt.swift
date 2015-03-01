//
//  Argument.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 3/1/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Foundation

internal class Argument: LeafPattern {
    override internal var description: String {
        get {
            return "Argument(\(name), \(value))"
        }
    }
}