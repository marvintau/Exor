Number:
	.ascii "%08X\n"

InputBufferLength:
	.quad   3	
InputBuffer:
        .ascii "All"
	.fill 	64, 1, 0x20 
InputBufferEnd:


StackPointer:
	.quad	0
Stack:
	.rept 	64
	.quad	0
	.endr
StackEnd:
