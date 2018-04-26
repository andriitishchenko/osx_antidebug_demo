#import <Foundation/Foundation.h>

#import <dlfcn.h>  
#import <sys/types.h>
typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);
#if !defined(PT_DENY_ATTACH)
#define PT_DENY_ATTACH 31
#endif  // !defined(PT_DENY_ATTACH)

 @interface Foo : NSObject
 @end
 @implementation Foo

 +(void)load {
 	NSLog (@"-- LOAD");
 	
	void* handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
	ptrace_ptr_t ptrace_ptr = dlsym(handle, "ptrace");
	ptrace_ptr(PT_DENY_ATTACH, 0, 0, 0);
	dlclose(handle);
 }
 @end

int main (int argc, const char * argv[]) {
    NSLog (@"-- MAIN");
    return 0;
}
