/**
 *  Exor experiment program
 *  =======================
 *  Containing learning notes and resources
 */
.data
.include "DataSegment.s"


.text
.include "IO.s"
.include "Stack.s"
.include "Execute.s"

.include "Dictionary.s"
.include "FindEntry.s"

.globl _main

# In order to save the number of argument and reduce the complexity
# of the macros, we are going to make some registers for special
# purpose, and not going to specify as arguments.


_main:
    InitDataStack
    InitStack

#MainLoop:

    # Enter the main routine
    leaq InitScan(%rip), %r11 
    jmp ExecuteSystemWord
    
    SystemExitLabel:
    movq $SyscallExit, %rax
    syscall
