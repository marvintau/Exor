
# Jumps from the beginning of entry to the place where the
# definition starts.

# In future, this part could be replaced with a different
# table, that sorts the entries with the frequency of use.
.macro MoveToDef EntryReg
	addq (\EntryReg), \EntryReg
	addq $0x9,   \EntryReg
.endm

// If you are curious about why not use a single instruction
// leaq DictEnd(%rip, \EntryReg), \EntryReg
// in the following macro, and borrow one more register %r15,
// the reason is RIP-relative addressing doesn't conform to
// the addressing form
// XXX Offset(%rip, indexReg, scaleReg), %reg

.macro MoveToNextEntry EntryReg
	movq -8(\EntryReg), \EntryReg
	leaq DictEnd(%rip), %r15
	leaq (%r15, \EntryReg), \EntryReg
.endm

.macro MoveToEntry EntryReg
	leaq DictEnd(%rip, \EntryReg), %r15
	leaq (%r15, \EntryReg), \EntryReg
.endm


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

	push %rcx

	leaq \InputBufferOffset, %r14

	CompareLen %r14, \EntryReg, CompareDone
	CompareChar %r14, \EntryReg, CompareDone
	CompareDone:

	pop %rcx

.endm


# Look up the dummy words table for the given word
.macro FindEntry

	// Initialize the dictionary pointer registers.
	leaq DictStart(%rip), %r13
	MoveToNextEntry %r13

	
	ForEachEntry:
		# Check entry table end
		cmpq $(0x0), (%r13)
		je LookUpDone

		Compare WordOffset(%rip), %r13
		jne NotMatching

		Matching:
			// Sanity check:
			// %r13 stores the intiial address of an entry
			// which points to the first byte of length quad
			PushStack %r13
		NotMatching:
			MoveToNextEntry %r13

	jmp ForEachEntry
	LookUpDone:
	
.endm
