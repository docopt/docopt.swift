//
//  calculator_example.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 3/9/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

let doc : String = "Naval Fate.\n" +
"\n" +
"Usage:\n" +
"  naval_fate.py ship new <name>...\n" +
"  naval_fate.py ship <name> move <x> <y> [--speed=<kn>]\n" +
"  naval_fate.py ship shoot <x> <y>\n" +
"  naval_fate.py mine (set|remove) <x> <y> [--moored|--drifting]\n" +
"  naval_fate.py -h | --help\n" +
"  naval_fate.py --version\n" +
"\n" +
"Options:\n" +
"  -h --help     Show this screen.\n" +
"  --version     Show version.\n" +
"  --speed=<kn>  Speed in knots [default: 10].\n" +
"  --moored      Moored (anchored) mine.\n" +
"  --drifting    Drifting mine.\n"

var args = Process.arguments
args.removeAtIndex(0) // arguments[0] is always the program_name
let result = Docopt.parse(doc, argv: args, help: true, version: "1.0")
print("Docopt result: \(result)")