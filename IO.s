.macro PrintStringInitial address
	pushq	%rax
        pushq   %rbx
	pushq	%rcx
	pushq   %rdi
	pushq	%rsi
	pushq	%rdx
        pushq   \address

	movq	$SyscallDisplay, %rax
	movq	$1, %rdi
        movq    $1, %rbx
	leaq	8(\address), %rsi
	movq	(\address), %rdx
	syscall
	
        popq    \address
	popq	%rdx
	popq	%rsi
	popq	%rdi
	popq	%rcx
        popq    %rbx
	popq	%rax
.endm

# Print String Constant
# =====================
# Uses system call.
PrintConstString:
    PrintStringInitial %r15
    ret
