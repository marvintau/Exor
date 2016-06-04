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

MainLoop:

    #ScanInputBuffer	
    ExecuteAllWords %r8, %r9, Find 
    
    jmp MainLoop

    movq $SyscallExit, %rax
    syscall

.align 8

DictEnd:
	.quad 0x000000000000

	StringDisplay God, "HE IS WHO HE IS\n"

	StringDisplay Jesus, "BELOVED SON\n"

	StringDisplay Adam, "FIRST CREATED MAN\n"

	StringDisplay Eve, "FIRST CREATED WOMAN\n"

        Code Exit
            PopStack %r13
        Beef:
        CodeEnd Exit

        Code Quit
            jmp ExecutionDone
        CodeEnd Quit

        Code TestCode
            movq $(0xbeef), %r11
        CodeEnd TestCode

        Word TestWord
            .quad TestCode 
        WordEnd TestWord

        Word TestWordS
            .quad TestWord
        WordEnd TestWordS


DictStart:
