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


.macro Prepare StrAddrReg, LengthReg, For, Action
	push \StrAddrReg
	push \LengthReg

	subq \LengthReg, \StrAddrReg
	incq \LengthReg
	call \Action

	popq \LengthReg
	popq \StrAddrReg
.endm

.macro CheckCharEdgeWith StrAddrReg, LengthReg, Action
		cmpb $(0x20), (\StrAddrReg)
		je   StartWithSpace
		jne  StartWithChar
	
	StartWithSpace:
		cmpb $(0x20), 1(\StrAddrReg)
		je   Done

		ButNextIsChar:
			movq $(0x0), \LengthReg
			jmp Done

	StartWithChar:
		cmpb $(0x20), 1(\StrAddrReg)
		// jne  HighKeep
		je   ButNextIsSpace

		StillChar:
			incq \LengthReg
			jmp  Done

		ButNextIsSpace:
			Prepare \StrAddrReg, \LengthReg, For, \Action
	Done:
		incq \StrAddrReg
.endm

.macro ApplyToUserInputWith Action, WithOffsetOf, StrAddrReg, AndLengthOf, LengthReg

	push %rcx
	push %rax
	leaq InputBuffer(%rip), \StrAddrReg
	movq InputBufferLength(%rip), %rcx
	// movq $(0x5), %rcx
	
	Apply_ForEachWord:
		push %rcx
		CheckCharEdgeWith \StrAddrReg, \LengthReg, \Action
		popq %rcx
		loop Apply_ForEachWord

	popq %rax
	popq %rcx
.endm
