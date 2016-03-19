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

	# Store buffer length
	movq	%rax, InputBufferLength(%rip)

.endm


.macro Prepare OffsetReg, LengthReg, For, Action
	push \OffsetReg
	push \LengthReg

	subq \LengthReg, \OffsetReg
	incq \LengthReg
	call \Action

	popq \LengthReg
	popq \OffsetReg
.endm

.macro CheckCharEdgeWith OffsetReg, LengthReg, Action
		cmpb $(0x20), (\OffsetReg)
		je   StartWithSpace
		jne  StartWithChar
	
	StartWithSpace:
		cmpb $(0x20), 1(\OffsetReg)
		je   Done

		ButNextIsChar:
			movq $(0x0), \LengthReg
			jmp Done

	StartWithChar:
		cmpb $(0x20), 1(\OffsetReg)
		// jne  HighKeep
		je   ButNextIsSpace

		StillChar:
			incq \LengthReg
			jmp  Done

		ButNextIsSpace:
			Prepare \OffsetReg, \LengthReg, For, \Action
	Done:
		incq \OffsetReg
.endm

.macro Apply Action, WithOffsetOf, OffsetReg, AndLengthOf, LengthReg

	push %rcx
	push %rax
	leaq InputBuffer(%rip), \OffsetReg
	movq InputBufferLength(%rip), %rcx
	// movq $(0x5), %rcx
	
	Apply_ForEachWord:
		push %rcx
		CheckCharEdgeWith \OffsetReg, \LengthReg, \Action
		popq %rcx
		loop Apply_ForEachWord

	popq %rax
	popq %rcx
.endm
