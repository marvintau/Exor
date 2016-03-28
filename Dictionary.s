# Now that the EntryReg is pointing to the first entry,
# The DictReg should not be used through the whole loop.
.macro InitDictionary EntryAddrReg, DictAddrReg
	leaq DictStart(%rip), \EntryAddrReg
	leaq DictEnd(%rip), \DictAddrReg

	MoveToNextEntry \EntryAddrReg, \DictAddrReg
	# Now it points to the first entry in Dictionary.
.endm


# Jumps from the beginning of entry to the place where the
# definition starts.

# In future, this part could be replaced with a different
# table, that sorts the entries with the frequency of use.
.macro MoveToDef EntryReg
	addq (\EntryReg), \EntryReg
	addq $0x8,   \EntryReg
.endm

.macro MoveToNextEntry EntryReg, DictReg
	movq -8(\EntryReg), \EntryReg
	leaq (\DictReg, \EntryReg), \EntryReg
.endm

# Apply operations over definitions with checking conditions
# Since the next entry can only be located with the address
# stored in EntryReg when entering the routine. Push it into
# stack before modify it.
.macro ApplyToDefWith Action, Cond, EntryReg, DictReg

	push \EntryReg
	MoveToDef \EntryReg
		
	dec \Cond
	je NotMatching

	Matching:
		ApplyString \EntryReg, With, \Action
	NotMatching:
		pop \EntryReg
		MoveToNextEntry \EntryReg, \DictReg

.endm
# How to test the function above:
# Just run it in a loop that iterate over whole dictionary,
# with outputing each entry.
# =========================================================

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

.macro CompareEntryWith EntryReg, StrAddrReg, StrLenReg, CondReg
	addq $0x8, \EntryReg
	Compare \StrAddrReg, \StrLenReg, \EntryReg, -8(\EntryReg), \CondReg
	subq $0x8, \EntryReg
.endm

# Look up the dummy words table for the given word
.macro FindEntry StrAddrReg, LengthReg, EntryReg, DictReg, CondReg

	InitDictionary \EntryReg, \DictReg

	ForEachEntry:

		# Check entry table end
		cmpq $(0x0), (\EntryReg)
		je LookUpDone

		CompareEntryWith \EntryReg, \StrAddrReg, \LengthReg, \CondReg

		ApplyToDefWith Print, \CondReg, \EntryReg, \DictReg
	jmp ForEachEntry
	LookUpDone:

.endm
