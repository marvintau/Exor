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

// Compare two strings. First check if the strings have equal length,
// then check if any different char exists. The piece of code doesn't
// affected the referred address registers except the counter.

// The lengths are typically passed as register. Thus no more indirect
// addressing needed.

// AFFECTED REGISTERS: rax, rcx
// AFFECTED FLAGS: ZF
.macro CompareString Length, Result, Str1, Len1, Str2, Len2

	movq \Len1, \Length
	subq $0x8,  \Length
	cmpq \Len2, \Length
	jne NotEqual

	// Macro counts the length of the bytes indicating the length
	// Subtract it to get the proper string length.
	ForEachCharacter:
		movb -1(\Str1, \Length), %al
		cmpb -1(\Str2, \Length), %al
		jne NotEqual
	loop ForEachCharacter

	jmp CompareStringDone
	NotEqual:
		movq $0x1, \Result

	CompareStringDone:
.endm

.macro CompareEntry Length, Result, Entry, StrPattern, StrLen
	addq $0x8, \Entry
	CompareString \Length, \Result, \Entry, -8(\Entry), \StrPattern, \StrLen
	subq $0x8, \Entry
.endm

.macro ApplyDefinitionWith Cond, Action
	// Move to defintiion
	addq (%r14), %r14

	dec \Cond
	je NotMatching

	Matching:
		addq $0x8, %r14
		\Action %r14, -8(%r14)
		subq $0x8, %r14
	NotMatching:
		addq (%r14), %r14

		// Jump to the next entry
.endm

// Look up the dummy words table for the given word
.macro LookUpEntry StrPattern, StrLen
	push %r14
	push %rax
	push %rdx
	
	leaq DummyWords(%rip), %r14

	ForEachEntry:
		// Check if proceeded to the end of table
		cmpw $(0xbeef), (%r14)
		je LookUpDone

		CompareEntry %rdx, %rax, %r14, \StrPattern, \StrLen

		ApplyDefinitionWith %rax, Print

	jmp ForEachEntry
	LookUpDone:

	pop %rdx
	pop %rax
	pop %r14
.endm