/**
 *  Exor experiment program
 *  =======================
 *  Containing learning notes and resources
 */
.data
.include "DataSegment.s"


.text
.include "IO.s"
.include "MatchWord.s"
.include "Lexer.s"
.include "Stack.s"
.include "FindEntry.s"
.include "EntryStructure.s"

.globl _main

# In order to save the number of argument and reduce the complexity
# of the macros, we are going to make some registers for special
# purpose, and not going to specify as arguments.

# r15 and r14: Reserved for string scan. 

PrintString:
	Print %r13, -8(%r13)
	ret

_main:
	InitStack

MainLoop:

	ScanInputBuffer	
	Parse
	ExecuteStack

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

	Entry All, EntryType.WordSeq
		.quad 2
		.quad EntryBeginGod
		.quad EntryBeginAdam
	EntryEnd All

	Entry All2, EntryType.WordSeq
		.quad 3
		.quad EntryBeginEve
		.quad EntryBeginJesus
		.quad EntryBeginAll
	EntryEnd All2

DictStart: