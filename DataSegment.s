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
	Entry\name:
	String Entry\name, "\name"
	.byte \EntryType
.endm

.macro EntryEnd name
	EntryEndOf\name:
		.quad (Entry\name - DictEnd)
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
		String DefGod, "He Is Who He Is\n"
	EntryEnd God

	Entry Jesus, EntryType.String
		String DefJesus, "Beloved Son\n"
	EntryEnd Jesus

	Entry Adam, EntryType.String
		String DefAdam, "First created man\n"
	EntryEnd Adam

	Entry Eve, EntryType.String
		String DefEve, "First created woman\n"
	EntryEnd Eve
DictStart:
