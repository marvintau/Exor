
# Jumps from the beginning of entry to the place where the
# definition starts.

# In future, this part could be replaced with a different
# table, that sorts the entries with the frequency of use.
.macro MoveToDef EntryReg
	addq (\EntryReg), \EntryReg
	addq $0x9,   \EntryReg
.endm

.macro MoveToNextEntry EntryReg
	push %r10
	movq -8(\EntryReg), \EntryReg
	leaq DictEnd(%rip), %r10
	leaq (%r10, \EntryReg), \EntryReg
	// leaq DictEnd(\EntryReg, %rip), \EntryReg
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

.macro CompareLen BuffReg, EntryReg, DoneLabel
	movq -8(\BuffReg), %rcx
	cmpq (\EntryReg), %rcx
	jne \DoneLabel

.endm

.macro CompareChar BuffReg, EntryReg, DoneLabel
	movq (\BuffReg), \BuffReg
	ForEachCharacter:		
		movb -1(\BuffReg, %rcx), %al
		cmpb  7(\EntryReg, %rcx), %al
		jne \DoneLabel
	loop ForEachCharacter
.endm

.macro Compare InputBufferOffset, EntryReg, ResultCond

	push %r13
	push %rcx

	leaq \InputBufferOffset, %r13

	CompareLen %r13, \EntryReg, CompareDone
	CompareChar %r13, \EntryReg, CompareDone
	CompareDone:

	pop %rcx
	pop %r13

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

	
	ForEachEntry:
		# Check entry table end
		cmpq $(0x0), (%r9)
		je LookUpDone

		Compare WordOffset(%rip), %r9
		jne NotMatching

		Matching:
			// Sanity check:
			// %r9 stores the intiial address of an entry
			// which points to the first byte of length quad
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
