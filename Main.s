/**
 *  Exor experiment program
 *  =======================
 *  Containing learning notes and resources
 */
.data
.include "DataSegment.s"


.text
.include "IO.s"
.include "Lexer.s"
.include "Stack.s"
.include "FindEntry.s"
.include "Execute.s"

.include "Dictionary.s"

.globl _main

# In order to save the number of argument and reduce the complexity
# of the macros, we are going to make some registers for special
# purpose, and not going to specify as arguments.

# r15 and r14: Reserved for string scan. 

_main:
    InitStack

#MainLoop:

    #ScanInputBuffer	
    ExecuteAllWords %r8, %r9 
    
    SystemExitLabel:

    movq $SyscallExit, %rax
    syscall
