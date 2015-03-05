#import <Foundation/Foundation.h>
@import Docopt;

static NSString *doc = 
   @"Usage: arguments_example.py [-vqrh] [FILE] ... \n"
    "          arguments_example.py (--left | --right) CORRECTION FILE\n"
    "\n"
    "Process FILE and optionally apply correction to either left-hand side or\n"
    "right-hand side.\n"
    "\n"
    "Arguments:\n"
    "  FILE        optional input file\n"
    "  CORRECTION  correction angle, needs FILE, --left or --right to be present\n"
    "\n"
    "Options:\n"
    "  -h --help\n"
    "  -v       verbose mode\n"
    "  -q       quiet mode\n"
    "  -r       make report\n"
    "  --left   use left-hand side\n"
    "  --right  use right-hand side\n";


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