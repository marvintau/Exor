.set SyscallExit,		0x2000001
.set SyscallDisplay,	0x2000004
.set SyscallRead,		0x2000003

.macro ScanInputBuffer
	movl	$SyscallRead, %eax
	movl	$(1), %edi
	leaq	InputBuffer(%rip), %rsi
	movq	$(InputBufferEnd - InputBuffer), %rdx
	syscall
	decq	%rax  // for ommitting the final enter key
	movq	%rax, InputBufferLength(%rip)
.endm

.macro ParseInputBuffer
	
	movq	InputBufferLength(%rip), %rcx
	leaq	InputBuffer(%rip), %r12
	leaq	UserLexusLength(%rip), %r13
	leaq	UserLexus(%rip), %r14
	leaq 	UserLexusOffset(%rip), %r15
	movq 	$(0x00), %rdx

	ForAllCharactersInInputBuffer:
		cmpb $(0x20), (%r12)
		jne IncreaseCurrentDelimiterInterval
		je  CreateNewDelimiterInterval
		
		IncreaseCurrentDelimiterInterval:
			incb (%r14)
			cmpq $(0x00), %rdx
			jne FinishedCheck
			
			MarkOffsetDone:
				movq $(0x01), %rdx

			jmp FinishedCheck

		CreateNewDelimiterInterval:
			cmpq $(0x00), %rdx
			je IncreaseOffset
			jne ContinueCheckDelimiters

			IncreaseOffset:
				incq (%r15)
				jmp FinishedCheck

			ContinueCheckDelimiters:
				cmpb $(0x00), (%r14)
				je FinishedCheck
				// Otherwise, 
					incq %r14
					incq (%r13)

		FinishedCheck:

		incq %r12

	loop ForAllCharactersInInputBuffer

	cmpq $(0x00), (%r14)
	je NotAddRemainingOne
	// Add Remaining one:
		incq (%r13)
	NotAddRemainingOne:
.endm


.macro Print address, length
	movq	$SyscallDisplay, %rax
	movq	$1, %rdi
	movq	\address, %rsi
	movzbq	\length, %rdx
	syscall
.endm

.macro EvaluateUserLexusWith ActionLabel
	movq	UserLexusLength(%rip), %rcx
	leaq	UserLexus(%rip), %r12
	leaq	InputBuffer(%rip), %r13

	addq	UserLexusOffset(%rip), %r13

	ForAllDelimiters:
		push %rcx

		call \ActionLabel

		// Fetch the offset from the UserLexus table
		// (the table records the offset of each word)
		// increase with 1 to omit the space, and then
		// add to the overall offset.
		movzbq (%r12), %r15
		incq %r15
		addq %r15, %r13

		// Move to the next word offset
		incq %r12

		pop %rcx
	loop ForAllDelimiters
.endm


.macro ExitProgram
	movq $SyscallExit, %rax
	syscall
.endm
