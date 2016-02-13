/**
 *  Exor experiment program
 *  =======================
 *  Containing learning notes and resources
 */

/** 
 * .section splits the code into segments. Conventionally
 * the segments are data and text segments, which contains
 * static data and executable instructions respectively. 
 */
.section __DATA,__data

/**
 * Notably, we add "\n" after all the strings. It seems like
 * the string won't show up if we omit the carriage return
 * for the string in the consequent calling of printf. A
 * possible reason is misaligning after calling. If we
 * compare the code with a piece of dumped assembly code from
 * a C program, like 
 */

/*
int main(){
    printf("hahaha");
    printf("%d", 4);
}
 */

# cc -S print.c

/*
 	pushq	%rbp
Ltmp0:
	.cfi_def_cfa_offset 16
Ltmp1:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
Ltmp2:
	.cfi_def_cfa_register %rbp
	subq	$16, %rsp
	leaq	L_.str(%rip), %rdi
	movb	$0, %al
	callq	_printf
	leaq	L_.str1(%rip), %rdi
	movl	$4, %esi
	movl	%eax, -4(%rbp)          ## 4-byte Spill
	movb	$0, %al
	callq	_printf
	xorl	%esi, %esi
	movl	%eax, -8(%rbp)          ## 4-byte Spill
	movl	%esi, %eax
	addq	$16, %rsp
	popq	%rbp
	retq
	.cfi_endproc
*/

/*
we could see that there are a lot of aligning work
done by the C compiler. I haven't figured it out 
yet and I'm not intended to follow the Unix/Darwin
calling convention in this work. I study it here
just because I need _printf something frequently
in the future, and I'm not likely to use any other
syscall.
 */
formatter:
  .asciz "A number example: %d\n"

welcome:
  .asciz "Hello the inner world!\n"


.section __TEXT,__text

.globl _main
_main:

/* 	CALLING CONVENTIONS OF X86-64
	=============================
	https://www.classes.cs.uchicago.edu/archive/2009/spring/22620-1/docs/handout-03.pdf
	
	Basically the caller will pass its frame pointer
	(the address where its stack starts) to the callee,
	which stored in %rbp. Thus here we push the %rbp to
	the stack. The caller's stack pointer will be also
	pass to callee, stored in %rsp, and will become callee's
	frame pointer.
 */
	pushq	%rbp
	movq	%rsp, %rbp

/* 	PREPARE TO CALL _printf
	=============================
	still from the same material, we know that the rax
	stores the syscall, and the integer arguments will
	be stores in the six registers. For here %rdi is the
	first argument, and %rsi will be the second.
	Another resources that contains more extensive
	discussion over calling conventions can be found at
	http://nickdesaulniers.github.io/blog/2014/04/18/lets-write-some-x86-64/
 */
	movq	$0, %rax

/* 	LOAD AND PRINT A STRING
	=======================
	Here we encounter two instructions, leaq and movq.
	The idea is to load a specific address into %rdi.
	GOT records the offset of all labels, and GOTPCREL
	should be GOT-Program Counter-Relative. Thus here
	the GOT calculates the relative distance from the
	current RIP to the label welcome. However, the leaq
	directly work out the distance and saves a lot of
	calculation.

	movq	welcome@GOTPCREL(%rip), %rdi
 */	
	leaq	welcome(%rip), %rdi
	callq	_printf
	
/* 	after calling _printf, the result will be stored in
	%rax. We want to see it, so we pass it to the second.
	And moreover, we have to reset rax back to zero,
	otherwise the function won't be called.
 */	
	movq	$0, %rax
	leaq	formatter(%rip), %rdi
	movq	$0x0539, %rsi
	callq	_printf

	popq	%rbp
	
	movl $0x2000000 | 1, %eax
	syscall
