//
//  calculator_example.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 3/5/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

let doc : String = "Not a serious example.\n" +
"\n" +
"Usage:\n" +
"  calculator_example.py <value> ( ( + | - | * | / ) <value> )...\n" +
"  calculator_example.py <function> <value> [( , <value> )]...\n" +
"  calculator_example.py (-h | --help)\n" +
"\n" +
"Examples:\n" +
"  calculator_example.py 1 + 2 + 3 + 4 + 5\n" +
"  calculator_example.py 1 + 2 '*' 3 / 4 - 5    # note quotes around '*'\n" +
"  calculator_example.py sum 10 , 20 , 30 , 40\n" +
"Options:\n" +
"  -h, --help\n"

var args = Process.arguments
args.removeAtIndex(0) // arguments[0] is always the program_name
let result = Docopt.parse(doc, argv: args, help: true, version: "1.0")
println("Docopt result: \(result)")