.set SyscallExit,		0x2000001
.set SyscallDisplay,	0x2000004
.set SyscallRead,		0x2000003

.macro Print address, length
	pushq	%rax
	pushq   %rdi
	pushq	%rsi
	pushq	%rdx

	movq	$SyscallDisplay, %rax
	movq	$1, %rdi
	movq	\address, %rsi
	movq	\length, %rdx
	syscall
	
	popq	%rdx
	popq	%rsi
	popq	%rdi
	popq	%rax
.endm

.macro PrintReg Reg
	push %rcx
	leaq Number(%rip), %rdi
	movq \Reg, %rsi
	movb $0, %al
	call _printf	
	pop  %rcx
.endm

.macro PrintBuffer address, length
	movq	$SyscallDisplay, %rax
	movq	$1, %rdi
	movq	\address, %rsi
	movq	\length, %rdx
	syscall
.endm

.macro ExitProgram
	
.endm
