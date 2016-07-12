.set SyscallExit,		0x2000001
.set SyscallDisplay,	        0x2000004
.set SyscallRead,		0x2000003

.macro Print address, length
	pushq	%rax
	pushq	%rcx
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
	popq	%rcx
	popq	%rax
.endm

# Print String Constant
# =====================
# Uses system call.
PrintConstString:
    Print %r15, -8(%r15)
    ret

.macro PrintReg Reg
	pushq	%rax
	pushq	%rcx
	pushq   %rdi
	pushq	%rsi
	pushq	%rdx

	leaq Number(%rip), %rdi
	movq \Reg, %rsi
	movb $0, %al
	call _printf	

	popq	%rdx
	popq	%rsi
	popq	%rdi
	popq	%rcx
	popq	%rax
.endm
