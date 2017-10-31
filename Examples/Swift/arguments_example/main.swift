//
//  arguments_example.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 3/9/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Docopt

let doc : String = """
Usage: arguments_example [-vqrh] [FILE] ...
       arguments_example (--left | --right) CORRECTION FILE

Process FILE and optionally apply correction to either left-hand side or right-hand side.

Arguments:
  FILE        optional input file
  CORRECTION  correction angle, needs FILE, --left or --right to be present

Options:
  -h --help
  -v       verbose mode
  -q       quiet mode
  -r       make report
  --left   use left-hand side
  --right  use right-hand side
"""

var args = CommandLine.arguments
_ = args.remove(at: 0) // arguments[0] is always the program_name
let result = Docopt.parse(doc, argv: args, help: true, version: "1.0")
print("Docopt result: \(result)")
