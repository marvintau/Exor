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

// Notably, since we have pushed string address register
// and length register here, it's safe to use them for
// different purpose in called Action subroutine. By
// convention, the two registers are %r14 and %r13
.macro Prepare StrAddrReg, LengthReg, For, Action
	push \StrAddrReg
	push \LengthReg

	subq \LengthReg, \StrAddrReg
	incq \LengthReg

	movq \StrAddrReg, WordOffset(%rip)
	movq \LengthReg, WordLength(%rip)
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
		je   ButNextIsSpace

		StillChar:
			incq \LengthReg
			jmp  Done

		ButNextIsSpace:
			Prepare \StrAddrReg, \LengthReg, For, \Action
	Done:
		incq \StrAddrReg
.endm

.macro Parse

	leaq InputBuffer(%rip), %r13
	movq InputBufferLength(%rip), %rcx

	// Handles zero lengthed user input
	test %rcx, %rcx
	je   Apply_ForEachWord_Done
	
	Apply_ForEachWord:
		push %rcx
		CheckCharEdgeWith %r13, %r14, Find
		popq %rcx
		loop Apply_ForEachWord
	Apply_ForEachWord_Done:

.endm
