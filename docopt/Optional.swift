//
//  Optional.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 3/1/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Foundation

internal class Optional: BranchPattern {
    override internal var description: String {
        get {
            return "Optional(\(children))"
        }
    }
}