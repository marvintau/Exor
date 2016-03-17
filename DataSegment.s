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
	Entry Adam, "First created man\n"
	Entry Eve, "First created woman\n"
	Entry God, "He Is Who He Is\n"
	.word 0xbeef 
EntriesEnd: