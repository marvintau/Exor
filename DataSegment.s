Number:
	.ascii "%08X\n"

WordOffset:
	.quad   0
WordLength:
	.quad   0
InputBufferLength:
	.quad	0
InputBuffer:
	.fill 	64, 1, 0x20 
InputBufferEnd:

.macro String name, content
	Length\name:
		.quad(End\name - Start\name)
	Start\name:
		.ascii "\content"
	End\name:
.endm

.set EntryType.String,  0x00
.set EntryType.WordSeq, 0x01

.macro Entry name, EntryType
	\name:
	String Entry\name, "\name"
	.byte \EntryType
.endm

.macro EntryEnd name
	EntryEndOf\name:
		.quad (\name - DictEnd)
.endm

StackPointer:
	.quad	0
Stack:
	.rept 	64
	.quad	0
	.endr
StackEnd:

DictEnd:
	.quad 0x000000000000
	Entry God, EntryType.String
		String God, "He Is Who He Is\n"
	EntryEnd God

	Entry Jesus, EntryType.String
		String Jesus, "Beloved Son\n"
	EntryEnd Jesus

	Entry Adam, EntryType.String
		String Adam, "First created man\n"
	EntryEnd Adam

	Entry Eve, EntryType.String
		String Eve, "First created woman\n"
	EntryEnd Eve

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
