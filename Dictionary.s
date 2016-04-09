
# Jumps from the beginning of entry to the place where the
# definition starts.

# In future, this part could be replaced with a different
# table, that sorts the entries with the frequency of use.
.macro MoveToDef EntryReg
	addq (\EntryReg), \EntryReg
	addq $0x8,   \EntryReg
.endm

.macro MoveToNextEntry EntryReg
	push %r10
	movq -8(\EntryReg), \EntryReg
	leaq DictEnd(%rip), %r10
	leaq (%r10, \EntryReg), \EntryReg
	// leaq DictEnd(%rip, \EntryReg), \EntryReg
	popq %r10
.endm

.macro MoveToEntry EntryReg
	push %r10
	leaq DictEnd(%rip, \EntryReg), %r10
	leaq (%r10, \EntryReg), \EntryReg
	popq %r10
.endm

# How to test the function above:
# Just run it in a loop that iterate over whole dictionary,
# with outputing each entry.
# =========================================================

# Compare two strings. First check if the strings have equal
# length, then check if any different char exists. The piece
# of code doesn't affected the referred address registers
# except the counter.

.macro Compare BuffOffReg, BuffLenReg, EntryReg, ResultCond

	push %rcx

	addq $0x8, \EntryReg

	movq \BuffLenReg, %rcx
	cmpq -8(\EntryReg), %rcx
	jne NotEqual

	ForEachCharacter:		
		movb -0x1(\BuffOffReg, %rcx), %al
		cmpb -0x1(\EntryReg, %rcx), %al
		jne NotEqual
	loop ForEachCharacter
		jmp CompareStringDone

	NotEqual:
		movq $0x1, \ResultCond

	CompareStringDone:

	subq $0x8, \EntryReg
	pop %rcx

.endm


# Look up the dummy words table for the given word
.macro FindEntry

	push %r8
	push %r9
	push %r12
	push %r13

	// Initialize the dictionary pointer registers.
	leaq DictStart(%rip), %r9
	MoveToNextEntry %r9

	movq WordOffset(%rip), %r13
	movq WordLength(%rip), %r12

	ForEachEntry:
		# Check entry table end
		cmpq $(0x0), (%r9)
		je LookUpDone

		Compare %r13, %r12, %r9, %r8
		dec %r8
		je NotMatching

		Matching:
			PushStack %r9
		NotMatching:
			MoveToNextEntry %r9

	jmp ForEachEntry
	LookUpDone:
	
	pop %r13
	pop %r12
	pop %r9
	pop %r8

.endm
