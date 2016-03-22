.set SyscallExit,		0x2000001
.set SyscallDisplay,	0x2000004
.set SyscallRead,		0x2000003

.section __DATA, __data
InputBufferLength:
	.quad	0
InputBuffer:
	.fill 	64, 1, 0x20 
InputBufferEnd:

.section __TEXT, __text
.globl _main

.macro Print

	movq	$SyscallDisplay, %rax
	movq	$(1), %rdi
	leaq	InputBuffer(%rip), %rsi
	movq	InputBufferLength(%rip), %rdx
	syscall

.endm

.macro ScanInputBuffer
	movq	$SyscallRead, %rax
	movq	$(1), %rdi
	leaq	InputBuffer(%rip), %rsi
	movq	$(InputBufferEnd - InputBuffer), %rdx
	syscall

	movq	%rax, InputBufferLength(%rip)
.endm

_main:

	ScanInputBuffer

	Print

	movq $SyscallExit, %rax
	syscall