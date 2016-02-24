# Define words that consists of other words.
.macro DefineWord name
	.section .rodata
	.align 8
	.globl NameLabel\name
NameLabel\name :
	.int link
	.set link,name_\label
	.byte \flags + (EndNameLabel\name - .)
	.ascii "\name"		// the name
EndNameLabel\name:
	.align 4		// padding to next 4 byte boundary
	.globl \label
\label :
	.int Momentum
.endm

# DefineCode defines the assembly code word in memory.
.macro DefineCode name
	.section .rodata
	.align 8
	.globl NameLabel\name
NameLabel\name :
	.int link		// link
	.set link,NameLabel\name
	.byte 
	.ascii "\name"		// the name
	.align 4		// padding to next 4 byte boundary
	.globl \label
CodeLabel\name :
	.int code_\label	// codeword
	.text
	//.align 4
	.globl code_\label
Code\name :			// assembler code follows
.endm

.macro DefineVariable name, flags=0, initial=0
	DefineCode \name
	push $Variable\name
	LoadJumpNext
	.data
	.align 4
Variable\name :
	.int \initial
.endm

.macro LoadJumpNext
	lodsq
	jmp *(%rax)
.endm

.macro PushReturnStack reg
	leaq -8(%rbp),%rbp
	movq \reg,(%rbp)
.endm

.macro PopReturnStack reg
	movq (%rbp),\reg
	leaq 8(%rbp),%rbp
.endm
