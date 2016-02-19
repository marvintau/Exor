.macro DisplayString StringLabel
	movl	$SyscallDisplay, %eax
	movl	$1, %edi
	movq	\StringLabel@GOTPCREL(%rip), %rsi
	movq	Size\StringLabel(%rip), %rdx
	syscall
.endm

.macro ExitProgram
	movl $SyscallExit, %eax
	syscall
.endm
