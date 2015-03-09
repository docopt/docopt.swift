``docopt.swift`` is a Swift port of docopt
======================================================================

**docopt.swift** helps you create most beautiful command-line interfaces
*easily*:

Swift:
```
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
```

Objective-C:
```
NSArray *arguments = [[NSProcessInfo processInfo] arguments];
arguments = arguments.count > 1 ? [arguments subarrayWithRange:NSMakeRange(1, arguments.count - 1)] : @[];

NSDictionary *result = [Docopt parse:doc argv:arguments help:YES version:@"1.0" optionsFirst:NO];
NSLog(@"Docopt result:\n%@", result);
```
