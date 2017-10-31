//
//  calculator_example.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 3/5/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Docopt

let doc : String = """
Not a serious example.

Usage:
  calculator_example <value> ( ( + | - | * | / ) <value> )...
  calculator_example <function> <value> [( , <value> )]...
  calculator_example (-h | --help)

Examples:
  calculator_example 1 + 2 + 3 + 4 + 5
  calculator_example 1 + 2 '*' 3 / 4 - 5    # note quotes around '*'
  calculator_example sum 10 , 20 , 30 , 40

Options:
  -h, --help
"""

var args = CommandLine.arguments
_ = args.remove(at: 0) // arguments[0] is always the program_name
let result = Docopt.parse(doc, argv: args, help: true, version: "1.0")
print("Docopt result: \(result)")
