/**
 *  Exor experiment program
 *  =======================
 *  Containing learning notes and resources
 */

.section __DATA, __data
.include "DataSegment.s"

.section __TEXT,__text
.include "IO.s"


.globl _main

# Momentum is the most cardinal part of Exor. Momentum pushes the
# result of the word onto the return stack, and fetches the next 
# word.
// Momentum:
// 	PushReturnStack %rsi 
// 	addq $8,%rax
// 	movq %rax,%rsi
// 	LoadJumpNext


_main:

	cld


	pushq	%rbp
	movq	%rsp, %rbp

	
	ScanStringBuffer
	ParseStringBuffer
	DisplayParsedStringBuffer
	popq	%rbp
	
	ExitProgram	
