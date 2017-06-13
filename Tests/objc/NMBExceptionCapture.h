#import <Foundation/Foundation.h>

@interface NMBExceptionCapture : NSObject

- (id)initWithHandler:(void(^)(NSException *))handler finally:(void(^)(void))finally;
- (void)tryBlock:(void(^)(void))unsafeBlock;

@end
