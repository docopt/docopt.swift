//
//  main.swift
//  docopt.swift.test
//
//  Created by Pavel Mazurin on 03/03/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Foundation

let doc = "Usage: prog [-v] A\n\n           Options: -v  Be verbose."
print(Docopt(doc).result)

