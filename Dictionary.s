.macro MoveNext Reg
	addq (\Reg), \Reg
	addq $0x8,   \Reg
.endm

.macro ApplyString Reg, With, Action
	addq $0x8, \Reg
	\Action \Reg, -8(\Reg)
	subq $0x8, \Reg
.endm

# Compare two strings. First check if the strings have equal
# length, then check if any different char exists. The piece
# of code doesn't affected the referred address registers
# except the counter.

.macro Compare StrOff1, StrLen1, StrOff2, StrLen2, ResultCond

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
		movq $0x1, \ResultCond

	CompareStringDone:
	pop %rcx
.endm

.macro CompareEntryWith EntryReg, OffsetReg, StrLenReg, CondReg
	addq $0x8, \EntryReg
	Compare \OffsetReg, \StrLenReg, \EntryReg, -8(\EntryReg), \CondReg
	subq $0x8, \EntryReg
.endm

.macro ApplyDefinition Action, Cond, EntryReg

	MoveNext \EntryReg
		
	dec \Cond
	je NotMatching

	Matching:
		ApplyString \EntryReg, With, \Action
	NotMatching:
		MoveNext \EntryReg

.endm

# Look up the dummy words table for the given word
.macro FindEntry OffsetReg, LengthReg, EntryReg, CondReg
	
	leaq Entries(%rip), \EntryReg

	ForEachEntry:

		# Check entry table end
		cmpw $(0xbeef), (\EntryReg)
		je LookUpDone

		CompareEntryWith \EntryReg, \OffsetReg, \LengthReg, \CondReg

		ApplyDefinition Print, \CondReg, \EntryReg
	jmp ForEachEntry
	LookUpDone:

.endm
