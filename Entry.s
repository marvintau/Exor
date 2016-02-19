/**
 *  Exor experiment program
 *  =======================
 *  Containing learning notes and resources
 */

.include "Data.s"
.include "Utils.s"

.section __DATA,__data

String Msg, "Yup.\n"

.set SyscallExit,		0x2000001
.set SyscallDisplay,	0x2000004

.section __TEXT,__text

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

.globl _main

momentum:
	PushReturnStack %rsi 
	addl $8,%rax
	movl %rax,%rsi
	LoadJumpNext


_main:

	pushq	%rbp
	movq	%rsp, %rbp

	DisplayString Msg

	popq	%rbp
	
	ExitProgram	
