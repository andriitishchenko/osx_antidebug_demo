## Max OSx anti debug test

All thanks to [this dude](https://cardaci.xyz/blog/2018/02/12/a-macos-anti-debug-technique-using-ptrace/ "this dude")


**AntiDebugDemo App has 2 schemes:**
- AntiDebugDemo -         debug works
- AntiDebugDemo Release - debug disabled


## Expected results:
After debugger run or attach, app will terminates:
**Process 36165 exited with status = 45 (0x0000002d) **


## How to:
open two terminal windows:
window 1:
navigate to .../Release/**AntiDebugDemo.app**/Contents/MacOS/
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
open window 2:
```sh
$sudo dtrace -q -n 'syscall:::entry /pid == $target && probefunc == "ptrace"/ { ustack(); }' -p 36165  <-- the pid from window#1
```
open window 1:
```sh
$(lldb) continue
Process 36165 resuming
2018-04-24 20:05:02.808616+0300 AntiDebugDemo[36165:3370918] -- AntiDebuger LOADED
Process 36165 exited with status = 45 (0x0000002d) 
(lldb) exit
```

Also check with:
```sh
$sudo dtrace -q -n 'syscall:::entry /pid == $target/ { printf("%s\n", probefunc); }' -p 35192 <-- the pid from window#1
```



