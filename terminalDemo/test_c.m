#import <Foundation/Foundation.h>
#include <sys/ptrace.h>

 @interface Foo : NSObject
 @end
 
@implementation Foo
+(void)load {
 	NSLog (@"-- LOAD");

    ptrace(PT_DENY_ATTACH, 0, 0, 0);
 }
 @end

int main (int argc, const char * argv[]) {
    NSLog (@"-- MAIN");
    return 0;
}
