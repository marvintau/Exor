.macro DefineDummyWord name explanation
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
DummyWords:
	DefineDummyWord God, "He Is Who He Is"
	DefineDummyWord Adam, "First created man"
	DefineDummyWord Eve, "First created woman"
	.word 0xbeef 
DummyWordsEnd:
.section __TEXT, __text

# Iterates over two strings with same length, exits once
# difference is found, or no differences found.
# AFFECTED REGISTERS: al(rax), rcx, r12, r13
# AFFECTED FLAGS: ZF
.macro CompareString StringPointer1, StringPointer2, Length

	pushq %r12
	pushq %r13

	movq \Length(%rip), %rcx
	leaq \StringPointer1(%rip), %r12
	leaq \StringPointer2(%rip), %r13

	ForEachCharacter:
		movb -1(%r12, %rcx), %al
		cmpb -1(%r13, %rcx), %al
		jne Done
	loop ForEachCharacter
	Done:

	popq  %r12
	popq  %r13
.endm

# Compares two length stored in memory
# AFFECTED FLAGS: ZF
.macro CompareLength Length1, Length2
	cmpq \Length1(%rip), \Length2(%rip)	
.endm

.macro CompareAllDummyWords
	
	pushq %r12
	pushq %r13

	leaq DummyWords(%rip), %r12

	ForEachEntry:
		movzwq (%r12), %r13
		cmpq $(0xbeef), %r13 # should be stop
		je ForEachEntryDone
		inc %r12
	jmp ForEachEntry
	ForEachEntryDone:

	popq %r12
	popq %r13
.endm