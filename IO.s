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
	
	movq	StringBufferLength(%rip), %rcx
	movq	StringBuffer@GOTPCREL(%rip), %r12
	movq	StringBufferDelimitersLength@GOTPCREL(%rip), %r13
	movq	StringBufferDelimiters@GOTPCREL(%rip), %r14
	movq 	StringBufferDelimitersOffset@GOTPCREL(%rip), %r15
	movq 	$(0x00), %rdx

	ForAllCharactersInStringBuffer:
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
				# Otherwise, 
					incq %r14
					incq (%r13)

		FinishedCheck:

		incq %r12

	loop ForAllCharactersInStringBuffer

	cmpq $(0x00), (%r14)
	je NotAddRemainingOne
	# Add Remaining one:
		incq (%r13)
	NotAddRemainingOne:
.endm

.macro DisplayParsedStringBuffer
	movq	StringBufferDelimitersLength(%rip), %rcx
	movq	StringBufferDelimiters@GOTPCREL(%rip), %r12
	movq	StringBuffer@GOTPCREL(%rip), %r13

	addq	StringBufferDelimitersOffset(%rip), %r13

	ForAllDelimiters:
	pushq	%rcx
		DisplayParsedString %r13, (%r12)
		DisplayStringConstant Return, "\n"
		movzbq (%r12), %r15		# move delimiter interval pointed by %r12 to %r15
		incq %r15				# increase the delimiter to omit the space
		addq %r15, %r13			# add the increment of pointer to buffer pointer
		incq %r12				# move to next delimiter interval
	popq	%rcx
	loop ForAllDelimiters
.endm

.macro ExitProgram
	movl $SyscallExit, %eax
	syscall
.endm
