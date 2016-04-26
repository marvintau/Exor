/**
 *  Exor experiment program
 *  =======================
 *  Containing learning notes and resources
 */
.section __DATA, __data
.include "DataSegment.s"


.section __TEXT, __text
.include "IO.s"
.include "Dictionary.s"
.include "Lexer.s"
.include "Stack.s"

.globl _main

# In order to save the number of argument and reduce the complexity
# of the macros, we are going to make some registers for special
# purpose, and not going to specify as arguments.

# r15 and r14: Reserved for string scan. 

PrintString:
	Print %r13, -8(%r13)
	ret

Find:
	FindEntry
	ret

_main:
	InitStack

// MainLoop:

	// ScanInputBuffer	
	Parse

	DepleteStack

	// jmp MainLoop

	movq $SyscallExit, %rax
	syscall

.macro String name, content
	Length\name:
		.quad(End\name - Start\name)
	Start\name:
		.ascii "\content"
	End\name:
.endm

.macro Entry name, EntryType
	\name:
	String Entry\name, "\name"
	.byte \EntryType
.endm

.macro EntryEnd name
	EntryEndOf\name:
		.quad (\name - DictEnd)
.endm

.macro StringDisplay name, string
	Entry \name, EntryType.Code
		jmp Skipped\name
			String \name, "\string"
		.align 8
		Skipped\name:
			push %r13
			leaq Start\name(%rip), %r13
			call PrintString
			pop  %r13
			jmp ExecuteDone
	EntryEnd \name
.endm

DictEnd:
	.quad 0x000000000000
	StringDisplay God, "HE IS WHO HE IS\n"

	StringDisplay Jesus, "BELOVED SON\n"

	StringDisplay Adam, "FIRST CREATED MAN\n"

	StringDisplay Eve, "FIRST CREATED WOMAN\n"

	Entry All, EntryType.WordSeq
		.quad 2
		.quad God
		.quad Adam
	EntryEnd All

	Entry All2, EntryType.WordSeq
		.quad 3
		.quad Eve
		.quad Jesus
		.quad All
	EntryEnd All2

DictStart: