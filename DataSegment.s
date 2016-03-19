InputBufferLength:
	.quad	0
InputBuffer:
	.fill 	64, 1, 0x20 
InputBufferEnd:

.macro String name, content
	\name:
		.quad(End\name - Start\name)
	Start\name:
		.ascii "\content"
	End\name:
.endm

.macro Entry name, definition
	String Entry\name, "\name"
	String Def\name, "\definition"
.endm

Entries:
	Entry God, "He Is Who He Is\n"
	Entry Jesus, "Beloved Son\n"
	Entry Adam, "First created man\n"
	Entry Eve, "First created woman\n"
	.word 0xbeef 
EntriesEnd: