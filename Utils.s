.set SyscallExit,		0x2000001
.set SyscallDisplay,	0x2000004

.macro DisplayString Label, String
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

.macro ExitProgram
	movl $SyscallExit, %eax
	syscall
.endm
