##One of possible solutions for prevent debugging is:
```c++
#include <sys/ptrace.h>

ptrace(PT_DENY_ATTACH, 0, 0, 0);
```
it can be added in main or +load.
Other variants are here: https://github.com/andriitishchenko/osx_antidebug_demo.git


###System calls
A system call is the programmatic way in which a computer program requests a service from the kernel of the operating system it is executed on.

In short, here's how a system call works:

- First, the user application program sets up the arguments for the system call.
- After the arguments are all set up, the program executes the "system call" instruction.
- This instruction causes an exception: an event that causes the processor to jump to a new address and start executing the code there.
- The instructions at the new address save your user program's state, figure out what system call you want, call the function in the kernel that implements that system call, restores your user program state, and returns control back to the user program.

 example: A C program invoking printf() library call, which calls write() system call.

- To make a system call the number of the syscall has to be passed in register %rax.   
	rdi - used to pass 1st argument to functions
	rsi - used to pass 2nd argument to functions
	rdx - used to pass 3rd argument to functions
	rcx - used to pass 4th argument to functions
	r8 - used to pass 5th argument to functions
	r9 - used to pass 6th argument to functions
	, then invoke syscall.
- Some system calls return information, usually in rax. A value in the range between -4095 and -1 indicates an error, it is -errno.
- The system call destroys rcx and r11 but others registers are saved across the system call.


It have padding: (0×2000000 + unix syscall #).
A full list is hosted by Apple here: http://www.opensource.apple.com/source/xnu/xnu-1504.3.12/bsd/kern/syscalls.master

List of system calls by groops: 
 https://jameshfisher.com/2017/01/31/macos-system-calls.html


### ptrace - process trace
 http://man7.org/linux/man-pages/man2/ptrace.2.html

ptrace is a system call which a program can use to:
- trace system calls, implement breakpoint debugging
- read and write memory and registers
- manipulate signal delivery to the traced process

It is used by strace, GDB, lldb, and other tools as well.
````c++
       #include <sys/ptrace.h>

       long ptrace(enum __ptrace_request request, pid_t pid,
                   void *addr, void *data);
````

- request — the action what need to be executed, for example: PTRACE_CONT, PTRACE_PEEKTEXT
- pid — processod ID
- addr и data depends form "request"

There are 2 options to start tracing:
- PTRACE_ATTACH - attach to runnig pid
- PTRACE_TRACEME - start the pid

For managing tracing the options can be used:
- PTRACE_SINGLESTEP — step by step execution. Each instruction will be tracked.
- PTRACE_SYSCALL — execution until system call invoked
- PTRACE_CONT — continue app running

Parent process calls ptrace with PTRACE_ATTACH, and his child calls ptrace with PTRACE_TRACEME option. This pair will connect two processes by filling some fields inside their task_struct (kernel/ptrace.c: sys_ptrace, child will have PT_PTRACED flag in ptrace field of struct task_struct, and pid of ptracer process as parent and in ptrace_entry list - __ptrace_link; parent will record child's pid in ptraced list).

Then strace will call ptrace with PTRACE_SYSCALL flag to register itself as syscall debugger, setting thread_flag  TIF_SYSCALL_TRACE in child process's struct thread_info (by something like set_tsk_thread_flag(child, TIF_SYSCALL_TRACE).

Description https://blog.packagecloud.io/eng/2016/02/29/how-does-strace-work/

Apple's Mac OS X also implements ptrace as a system call. Apple's version adds a special option PT_DENY_ATTACH - if a process invokes this option on itself, subsequent attempts to ptrace the process will fail. Apple uses this feature to limit the use of debuggers on programs that manipulate DRM-ed content, including iTunes. PT_DENY_ATTACH on also disables DTrace's ability to monitor the process.Debuggers on OS X typically use a combination of ptrace and the Mach VM and thread APIs.ptrace (again with PT_DENY_ATTACH) is available to developers for the Apple iPhone.


### DTrace 
DTrace is a performance analysis and troubleshooting tool that is included by default with various operating systems, including Solaris, Mac OS X and FreeBSD. 

The name is short for Dynamic Tracing: an instrumentation technique pioneered by DTrace which dynamically patches live running instructions with instrumentation code. The DTrace facility also supports Static Tracing: where user-friendly trace points are added to code and compiled-in before deployment.

DTrace provides a language, ‘D’, for writing DTrace scripts and one-liners. The language is like C and awk, and provides powerful ways to filter and summarize data in-kernel before passing to user-land. 

We can use it to check ptrace:
```sh
$lldb ./AntiDebugDemo 
(lldb) target create "./AntiDebugDemo"
Current executable set to './AntiDebugDemo' (x86_64).
```
```sh
(lldb) process launch --stop-at-entry
Process 36165 stopped
* thread #1, stop reason = signal SIGSTOP
    frame #0: 0x000000010000819c dyld`_dyld_start
dyld\`_dyld_start:
->  0x10000819c <+0>: popq   %rdi
    0x10000819d <+1>: pushq  $0x0
    0x10000819f <+3>: movq   %rsp, %rbp
    0x1000081a2 <+6>: andq   $-0x10, %rsp
Target 0: (AntiDebugDemo) stopped.
Process 36165 launched: './AntiDebugDemo' (x86_64)
```
```sh
$sudo dtrace -q -n 'syscall:::entry /pid == $target && probefunc == "ptrace"/ { ustack(); }' -p 36165
```

