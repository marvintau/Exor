.set SyscallExit,		0x2000001
.set SyscallDisplay,	0x2000004
.set SyscallRead,		0x2000003

.macro DisplayStringConstant Label, String
	.data
\Label:
	.asciz "\String"
Size\Label:
	.quad . - \Label

	.text
Display\Label:
	movl	$SyscallDisplay, %eax
	movl	$1, %edi
	movq	\Label@GOTPCREL(%rip), %rsi
	movq	Size\Label(%rip), %rdx
	syscall
.endm

.macro DisplayStringBuffer
	movl	$SyscallDisplay, %eax
	movl	$(1), %edi
	movq	StringBuffer@GOTPCREL(%rip), %rsi
	movq	StringBufferLength(%rip), %rdx
	// movq	$(16), %rdx
	syscall
.endm

.macro DisplayParsedString address, length
	movl	$SyscallDisplay, %eax
	movl	$(1), %edi
	movq	\address, %rsi
	movzbq	\length, %rdx
	syscall
.endm

.macro ScanStringBuffer
	movl	$SyscallRead, %eax
	movl	$(1), %edi
	movq	StringBuffer@GOTPCREL(%rip), %rsi
	movq	$(StringBufferEnd - StringBuffer), %rdx
	syscall
	decq	%rax  # enter should be ommited
	movq	%rax, StringBufferLength(%rip)
.endm

.macro ParseStringBuffer
	
	# We are going to use the last (and least used) four 
	# registers to perform the loop. The usage of registers
	# might be modified when migrating to different platforms.

	# Here we make a convention of making a loop for
	# convenience and clarity. The loop variable (the one
	# that keeps decreasing) should be assigned first, then
	# the affected address (pointer) in same buffer, and then
	# the other less-related variable and pointers.

	# Since almost all memory that indicating length of buffer
	# have same length (quadword), it's okay to address the
	# buffer by using
	#
	# addq (StringBufferLength + Offset)(%rip), %rax
	#
	# instead of saving it into registers in advance. However
	# this would make the whole procedure take several times
	# of more cycles. This is what the registers are made for.

	// xorq	%rcx, %rcx
	movq	StringBufferLength(%rip), %rcx
	movq	StringBuffer@GOTPCREL(%rip), %r12
	movq	StringBufferDelimitersLength@GOTPCREL(%rip), %r13
	movq	StringBufferDelimiters@GOTPCREL(%rip), %r14
	movq 	StringBufferDelimitersOffset@GOTPCREL(%rip), %r15
	movq 	$(0x00), %rdx

	IterateOverStringBuffer:
		cmpb $(0x20), (%r12)
		jne AddCurrentLength
		je  CreateNewLength
		
		AddCurrentLength:
			# If the scanned character IS NOT a space, then
			# add the BYTE in the memory where %r14 points to
			# by 1.
			incb (%r14)
			cmpq $(0x00), %rdx
			jne FinishedCheck
			
			MarkOffsetDone:
				movq $(0x01), %rdx

			jmp FinishedCheck

		CreateNewLength:
			# If the scanned character IS a space, then check
			# the current byte that %r14 points to is zero,
			# which means the LAST scanned character is ALSO
			# a space. Do nothing in this case.
			cmpq $(0x00), %rdx
			je IncreaseOffset
			jne ContinueCheckDelimiters

			IncreaseOffset:
				incq (%r15)
				jmp FinishedCheck

			ContinueCheckDelimiters:
				cmpb $(0x00), (%r14)
				je FinishedCheck
				# Otherwise, 
					incq %r14
					incq (%r13)

		FinishedCheck:

		incq %r12

	loop IterateOverStringBuffer

	cmpq $(0x00), (%r14)
	je NotAddRemainingOne
	# Add Remaining one:
		incq (%r13)
	NotAddRemainingOne:
.endm

// .set   DelimitersOffset, 0
.macro DisplayParsedStringBuffer
	movq	StringBufferDelimitersLength(%rip), %rcx
	movq	StringBufferDelimiters@GOTPCREL(%rip), %r12
	movq	StringBuffer@GOTPCREL(%rip), %r13

	addq	StringBufferDelimitersOffset(%rip), %r13

	IterateOverStringBufferDelimiters:
	pushq	%rcx
		DisplayParsedString %r13, (%r12)
		DisplayStringConstant Return, "\n"
		movzbq (%r12), %r15
		incq %r15
		addq %r15, %r13
		incq %r12
	popq	%rcx
	loop IterateOverStringBufferDelimiters
.endm

.macro ExitProgram
	movl $SyscallExit, %eax
	syscall
.endm
