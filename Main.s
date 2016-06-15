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
.include "EntryStructure.s"
.include "Execute.s"

.globl _main

# In order to save the number of argument and reduce the complexity
# of the macros, we are going to make some registers for special
# purpose, and not going to specify as arguments.

# r15 and r14: Reserved for string scan. 

_main:
    InitStack

#MainLoop:

    #ScanInputBuffer	
    ExecuteAllWords %r8, %r9, Find 
    
    #jmp MainLoop
Don:

    movq $SyscallExit, %rax
    syscall

.align 8

DictEnd:
	.quad 0x000000000000

	StringDisplay Jesus, "BELOVED SON\n"

        Code Exit
            PopStack %r13
        CodeEnd Exit

        Code Quit
            jmp ExecutionDone
        CodeEnd Quit

        Word JesusWord
            .quad Jesus 
        WordEnd JesusWord


DictStart:
