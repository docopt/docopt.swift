//
//  docopt.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 2/28/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Foundation

public class Docopt {
    public let result: AnyObject
    
    public init(doc: String, argv: [String], help: Bool = false, optionsFirst: Bool = false) {
        result = [:]
    }
}