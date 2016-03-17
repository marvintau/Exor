/**
 *  Exor experiment program
 *  =======================
 *  Containing learning notes and resources
 */

.section __TEXT, __text
.include "ScanBuffer.s"
.include "ExorMacros.s"
.include "LexTable.s"
.include "IO.s"

.globl _main

PrintWord:
	Print %r15, %r14
	ret

FindEntry:
	LookUpEntryWithStringOffsetReg %r15, AndLengthReg, %r14, WithEntryReg, %r13, UsingCondReg, %r12
	ret

_main:

	ScanInputBuffer
	
	Apply FindEntry, WithOffsetOf, %r15, AndLengthof, %r14

	movq $SyscallExit, %rax
	syscall

.section __DATA, __data
.include "DataSegment.s"
