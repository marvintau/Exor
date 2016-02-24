# Used by DisplayRegister
RegDump:
	.quad	0

# Used by ScanStringBuffer
StringBuffer:
	.fill 	256, 1, 0xFF 
StringBufferEnd:
StringBufferPointer:
	.quad	0


.set RETURN_STACK_SIZE,256
.set BUFFER_SIZE, 256

/* FORTH return stack. */
	.align 8
ReturnStack:
	.space RETURN_STACK_SIZE
ReturnStackTop:		// Initial top of return stack.
/* This is used as a temporary input buffer when reading from files or the terminal. */
	.align 8
Buffer:
	.space BUFFER_SIZE