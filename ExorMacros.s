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

# Compare two strings. First check if the strings have equal length,
# then check if any different char exists. The piece of code doesn't
# affected the referred address registers except the counter.

# The lengths are typically passed as register. Thus no more indirect
# addressing needed.

# AFFECTED REGISTERS: rax, rcx
# AFFECTED FLAGS: ZF
.macro CompareString StringPointer1, StringPointer2, Length1, Length2

	movq \Length2, %rcx
	cmpq \Length1, %rcx
	jne NotEqual

	// subq $0x8, %rcx
	ForEachCharacter:
		movb -1(\StringPointer1, %rcx), %al
		movb -1(\StringPointer2, %rcx), %bl
		cmpb %al, %bl
		jne NotEqual
	loop ForEachCharacter

	jmp CompareStringDone
	NotEqual:
		movq $0x1, %rax

	CompareStringDone:
.endm

# Look up the dummy words table for the given word
.macro LookUpDummyWords GivenStringPattern, GivenStringPatternLength
	
	# DummyWords table begins with the length of first entry word
	leaq DummyWords(%rip), %r14

	ForEachEntry:
		# Check if proceeded to the end of table
		cmpw $(0xbeef), (%r14)
		je LookUpDone

		# Move 8 bytes (a quad) to align to the starting of string
		addq $0x8, %r14
		CompareString %r14, \GivenStringPattern, -8(%r14), \GivenStringPatternLength
		subq $0x8, %r14

		# Move to definition, await for branching
		addq (%r14), %r14

		dec %rax
		je NotMatching

		Matching:
			addq $0x8, %r14
			DisplayUserLexus %r14, -8(%r14)
			subq $0x8, %r14
		NotMatching:
			# Jump to the next entry
			addq (%r14), %r14

	jmp ForEachEntry
	LookUpDone:

.endm