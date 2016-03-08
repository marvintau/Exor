.macro DefineDummyWord name explanation
	.align 8
	.globl DummyWord\name

DummyWord\name:
	.quad (EndDummyWord\name - .)
	.ascii "\name"
EndDummyWord\name:

ExplainLabel\name:
	.quad (EndExplainLabel\name - .)
	.ascii "\explanation"
EndExplainLabel\name:
.endm

.section __DATA, __data
DummyWord:
	DefineDummyWord Adam, "First created man"
	# DefineDummyWord Eve, "First created woman"
DummyWordEnd:
.section __TEXT, __text

# Iterates over two string with same length, exits once difference
# is found, or no difference found.
# AFFECTED REGISTERS: al(rax), rcx, r12, r13
.macro CompareString StringPointer1, StringPointer2, Length

	movq \Length(%rip), %rcx
	leaq \StringPointer1(%rip), %r12
	leaq \StringPointer2(%rip), %r13

	ForEachCharacter:
		movb -1(%r12, %rcx), %al
		cmpb -1(%r13, %rcx), %al
		jne Done
	loop ForEachCharacter
	Done:
.endm

.macro FindDummyWord
	
.endm