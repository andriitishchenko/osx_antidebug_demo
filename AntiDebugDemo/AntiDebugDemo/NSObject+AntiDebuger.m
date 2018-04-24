//
//  NSObject+AntiDebuger.m
//  AntiDebugDemo
//
//  Created by Andrii Tishchenko on 4/24/18.
//  Copyright © 2018 Andrii Tishchenko. All rights reserved.
//

#import "NSObject+AntiDebuger.h"
#include <assert.h>
#include <stdbool.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/sysctl.h>

@implementation NSObject (AntiDebuger)
#ifndef DEBUG
+(void)load {
  NSLog (@"-- AntiDebuger LOADED");
  asm("movq $0, %rcx");
  asm("movq $0, %rdx");
  asm("movq $0, %rsi");
  asm("movq $0x1f, %rdi");      /* PT_DENY_ATTACH 31 (0x1f)*/
  asm("movq $0x200001a, %rax"); /* ptrace syscall number 26 (0x1a) */
  asm("syscall");
}
#endif
@end

/*
 https://developer.apple.com/library/content/qa/qa1361/_index.html
 // Returns true if the current process is being debugged (either
 // running under the debugger or has a debugger attached post facto).
 */
bool AmIBeingDebugged(void) {
  int                 junk;
  int                 mib[4];
  struct kinfo_proc   info;
  size_t              size;
  
    // Initialize the flags so that, if sysctl fails for some bizarre
    // reason, we get a predictable result.
  
  info.kp_proc.p_flag = 0;
  
    // Initialize mib, which tells sysctl the info we want, in this case
    // we're looking for information about a specific process ID.
  
  mib[0] = CTL_KERN;
  mib[1] = KERN_PROC;
  mib[2] = KERN_PROC_PID;
  mib[3] = getpid();
  
    // Call sysctl.
  
  size = sizeof(info);
  junk = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
  assert(junk == 0);
  
    // We're being debugged if the P_TRACED flag is set.
  
  return ( (info.kp_proc.p_flag & P_TRACED) != 0 );
}
