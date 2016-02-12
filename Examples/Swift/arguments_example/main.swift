//
//  arguments_example.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 3/9/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Docopt

let doc : String = "Usage: arguments_example.py [-vqrh] [FILE] ... \n" +
"          arguments_example.py (--left | --right) CORRECTION FILE\n" +
"\n" +
"Process FILE and optionally apply correction to either left-hand side or\n" +
"right-hand side.\n" +
"\n" +
"Arguments:\n" +
"  FILE        optional input file\n" +
"  CORRECTION  correction angle, needs FILE, --left or --right to be present\n" +
"\n" +
"Options:\n" +
"  -h --help\n" +
"  -v       verbose mode\n" +
"  -q       quiet mode\n" +
"  -r       make report\n" +
"  --left   use left-hand side\n" +
"  --right  use right-hand side\n"

var args = Process.arguments
args.removeAtIndex(0) // arguments[0] is always the program_name
let result = Docopt.parse(doc, argv: args, help: true, version: "1.0")
print("Docopt result: \(result)")