.macro MoveNextString WithOffsetReg, Reg
	addq (\Reg), \Reg
	addq $0x8,   \Reg
.endm

.macro ApplyString OverOffsetReg, Reg, With, Action
	addq $0x8, \Reg
	\Action \Reg, -8(\Reg)
	subq $0x8, \Reg
.endm

# Compare two strings. First check if the strings have equal
# length, then check if any different char exists. The piece
# of code doesn't affected the referred address registers
# except the counter.

.macro Compare StrOff1, StrLen1, AndString, StrOff2, StrLen2, StoringCondAt, Result

	push %rcx

	movq \StrLen1, %rcx
	cmpq \StrLen2, %rcx
	jne NotEqual

	ForEachCharacter:
		
		movb -0x1(\StrOff1, %rcx), %al
		cmpb -0x1(\StrOff2, %rcx), %al
		jne NotEqual
	loop ForEachCharacter

	jmp CompareStringDone
	NotEqual:
		movq $0x1, \Result

	CompareStringDone:
	pop %rcx
.endm

.macro CompareEntryWith EntryReg, AndStringWithOffset, OffsetReg, AndLength, StrLenReg, StoringCondAt, CondReg
	addq $0x8, \EntryReg
	Compare \OffsetReg, \StrLenReg, AndString, \EntryReg, -8(\EntryReg), StoringCondAt, \CondReg
	subq $0x8, \EntryReg
.endm

.macro ApplyDefinitionWith Action, BySatisfying, Cond, AtEntryReg, EntryReg

	MoveNextString WithOffsetReg, \EntryReg
		
	dec \Cond
	je NotMatching

	Matching:
		ApplyString OverOffsetReg, \EntryReg, With, \Action
	NotMatching:
		MoveNextString WithOffsetReg, \EntryReg

.endm

# Look up the dummy words table for the given word
.macro LookUpEntryWithStringOffsetReg OffsetReg, AndLengthReg, LengthReg, WithEntryReg, EntryReg, UsingCondReg, CondReg
	
	leaq Entries(%rip), \EntryReg

	ForEachEntry:

		# Check if proceeded to the end of table
		cmpw $(0xbeef), (\EntryReg)
		je LookUpDone

		CompareEntryWith \EntryReg, AndStringWithOffset, \OffsetReg, AndLength, \LengthReg, StoringCondAt, \CondReg

		ApplyDefinitionWith Print, BySatisfying, \CondReg, AtEntryReg, \EntryReg
		# MoveNext %r14
	jmp ForEachEntry
	LookUpDone:

.endm
