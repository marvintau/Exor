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

PrintWord:
	Print %r15, %r14
	ret

Find:
	FindEntry %r15, %r14, %r13, %r12, %r11
	ret

_main:

MainLoop:
	xorq %r15, %r15
	xorq %r14, %r14 
	xorq %r13, %r13
	xorq %r12, %r12
	xorq %r11, %r11

	ScanInputBuffer	
	ApplyToUserInputWith Find, WithOffsetOf, %r15, AndLengthof, %r14

	InitStack %r15

	jmp MainLoop

	movq $SyscallExit, %rax
	syscall

.section __DATA, __data
.include "DataSegment.s"
