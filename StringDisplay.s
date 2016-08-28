
# OUTPUT STRING CONSTANT
# ======================
# A handful macro that defines a code word that output a string. Useful
# in debugging stage, but considered to be removed in future release,
# since a general word that output given string address will be more 
# efficient, and takes less space.

# Before we developed the word that enables us to define string in run
# time, we will keep using this one.

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

.macro StringConst name, string
    Code \name

        jmp SkippedContent\name
            String Content\name, "\string"
        SkippedContent\name:
            push %r15
            leaq Content\name(%rip), %r15
            leaq -8(%r15), %r15
            PrintStringInitial %r15
            pop  %r15       

    CodeEnd \name

.endm

StringConst Jesus, "BELOVED SON\n"
StringConst Maria, "THE VIRGIN\n"
