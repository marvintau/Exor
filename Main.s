/**
 *  Exor experiment program
 *  =======================
 *  Containing learning notes and resources
 */

.section __TEXT, __text
.include "Dictionary.s"
.include "Lexer.s"
.include "Stack.s"
.include "IO.s"

.globl _main

# In order to save the number of argument and reduce the complexity
# of the macros, we are going to make some registers for special
# purpose, and not going to specify as arguments.

# r15 and r14: Reserved for string scan. 


Find:
	FindEntry
	ret

_main:

MainLoop:

	ScanInputBuffer	
	Evaluate

	// InitStack %r15

	jmp MainLoop

	movq $SyscallExit, %rax
	syscall

.section __DATA, __data
.include "DataSegment.s"
