Number:
	.ascii "%08X\n"

WordLength:
	.quad   0
WordOffset:
	.quad   0
InputBufferLength:
	.quad	10
InputBuffer:
	.fill 	64, 1, 0x20 
InputBufferEnd:

.set EntryType.Code,  0x00
.set EntryType.WordSeq, 0x01

StackPointer:
	.quad	0
Stack:
	.rept 	64
	.quad	0
	.endr
StackEnd: