Number:
	.ascii "%08X\n"

InputBufferLength:
	.quad   3	
InputBuffer:
        .ascii "All Adam"
	.fill 	64, 1, 0x20 
InputBufferEnd:

Stack:
	.rept 	64
	.quad	0
	.endr
StackEnd:
