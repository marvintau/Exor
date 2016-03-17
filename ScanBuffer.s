# Used by ScanInputBuffer
.macro ScanInputBuffer
	movq	$SyscallRead, %rax
	movl	$(1), %edi
	leaq	InputBuffer(%rip), %rsi
	movq	$(InputBufferEnd - InputBuffer), %rdx
	syscall

	# replace the final enter (carriage return)
	# as a white space, for falling edge check
	# when parsing
	decq	%rax
	movq	$(0x20), (%rsi, %rax)

	movq	%rax, InputBufferLength(%rip)

.endm
