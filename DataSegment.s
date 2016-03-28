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

.macro Entry name, definition
	Entry\name:
	String Entry\name, "\name"
	String Def\name, "\definition"

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
	Entry God, "He Is Who He Is\n"
	Entry Jesus, "Beloved Son\n"
	Entry Adam, "First created man\n"
	Entry Eve, "First created woman\n"
DictStart:
