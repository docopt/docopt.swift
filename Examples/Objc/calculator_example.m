#import <Foundation/Foundation.h>
@import Docopt;

static NSString *doc =
   @"Not a serious example.\n"
    "\n"
    "Usage:\n"
    "  calculator_example.py <value> ( ( + | - | * | / ) <value> )...\n"
    "  calculator_example.py <function> <value> [( , <value> )]...\n"
    "  calculator_example.py (-h | --help)\n"
    "\n"
    "Examples:\n"
    "  calculator_example.py 1 + 2 + 3 + 4 + 5\n"
    "  calculator_example.py 1 + 2 '*' 3 / 4 - 5    # note quotes around '*'\n"
    "  calculator_example.py sum 10 , 20 , 30 , 40\n"
    "\n"
    "Options:\n"
    "  -h, --help\n";

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // Use arguments passed from command line
        NSArray *arguments = [[NSProcessInfo processInfo] arguments];
        arguments = arguments.count > 1 ? [arguments subarrayWithRange:NSMakeRange(1, arguments.count - 1)] : @[];
        
        // Parse with Docopt
        NSDictionary *result = [Docopt parse:doc argv:arguments help:YES version:@"1.0" optionsFirst:NO];
        NSLog(@"Docopt result:\n%@", result);
    }
    return 0;
}
