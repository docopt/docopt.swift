#import <Foundation/Foundation.h>
@import Docopt;

static NSString *doc = 
   @"Naval Fate.\n"
    "\n"
    "Usage:\n"
    "  naval_fate.py ship new <name>...\n"
    "  naval_fate.py ship <name> move <x> <y> [--speed=<kn>]\n"
    "  naval_fate.py ship shoot <x> <y>\n"
    "  naval_fate.py mine (set|remove) <x> <y> [--moored|--drifting]\n"
    "  naval_fate.py -h | --help\n"
    "  naval_fate.py --version\n"
    "\n"
    "Options:\n"
    "  -h --help     Show this screen.\n"
    "  --version     Show version.\n"
    "  --speed=<kn>  Speed in knots [default: 10].\n"
    "  --moored      Moored (anchored) mine.\n"
    "  --drifting    Drifting mine.\n";


int main(int argc, const char * argv[])
{
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