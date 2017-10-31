//
//  calculator_example.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 3/9/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Docopt

let doc : String = """
Naval Fate.

Usage:
  naval_fate ship new <name>...
  naval_fate ship <name> move <x> <y> [--speed=<kn>]
  naval_fate ship shoot <x> <y>
  naval_fate mine (set|remove) <x> <y> [--moored|--drifting]
  naval_fate -h | --help
  naval_fate --version

Options:
  -h --help     Show this screen.
  --version     Show version.
  --speed=<kn>  Speed in knots [default: 10].
  --moored      Moored (anchored) mine.
  --drifting    Drifting mine.
"""

var args = CommandLine.arguments
_ = args.remove(at: 0) // arguments[0] is always the program_name
let result = Docopt.parse(doc, argv: args, help: true, version: "1.0")
print("Docopt result: \(result)")
