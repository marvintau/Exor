
# Used by ParseStringBuffer
# The length should always be the half of StringBuffer
StringBufferDelimitersOffset:
	.quad	0
StringBufferDelimitersLength:
	.quad	0
StringBufferDelimiters:
	.fill	128, 1, 0x00
StringBufferDelimitersEnd:

# Used by ScanStringBuffer
StringBufferLength:
	.quad	0
StringBuffer:
	.fill 	256, 1, 0x00 
StringBufferEnd:


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