	.set RETURN_STACK_SIZE,8192
	.set BUFFER_SIZE, 4096

	.bss
/* FORTH return stack. */
	.align 12
ReturnStack:
	.space RETURN_STACK_SIZE
ReturnStackTop:		// Initial top of return stack.
/* This is used as a temporary input buffer when reading from files or the terminal. */
	.align 12
Buffer:
	.space BUFFER_SIZE