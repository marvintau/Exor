
// Jumps from the beginning of entry to the place where the
// definition starts.

// GoToNextEntry is exclusively used in FindEntry.
.macro GoToNextEntry EntryReg
	push %r15

	// We know that when GoToNextEntry is called, %r13
	// holds the EntryBegin\name label, thus we need to
	// move back to the beginning of the next entry. We
	// need to subtract the distance stored in the quad
	// that immediately after the label, then 8 bytes.
	subq (\EntryReg), \EntryReg
	movq -8(\EntryReg), \EntryReg

	// By far the EntryReg is storing the offset from
	// the Dictionary head to PREVIOUS entry.
	leaq DictEnd(%rip), %r15
	leaq (%r15, \EntryReg), \EntryReg
	pop  %r15
.endm

.macro GoToFirstEntry EntryReg
	push %r15

	// Slightly different from GoToNextEntry, at first
	// the \EntryReg is not pointing to something like
	// entry beginning. Thus we just move 8 bytes back
	// and perform the exactly same thing.
	movq -8(\EntryReg), \EntryReg
	leaq DictEnd(%rip), %r15
	leaq (%r15, \EntryReg), \EntryReg	
	pop  %r15
.endm

// This is particularly used in PopStack, for jump to entry
// with given entry address.
.macro GoToEntry EntryReg
	leaq DictEnd(%rip, \EntryReg), %r15
	leaq (%r15, \EntryReg), \EntryReg
.endm



.macro FindEntry EntryReg

	// Initialize the dictionary pointer registers.
	leaq DictStart(%rip), \EntryReg
	GoToFirstEntry \EntryReg

	
	ForEachEntry:
		// Check if dictionary end reached
		cmpq $(0x0), (\EntryReg)
		je LookUpDone

		// Jump to entry-defined matching subroutine.
		// Matching subroutine has to return to MatchDone
		jmp *\EntryReg
		MatchDone:
			jne NotMatching

		Matching:
			// Sanity check:
			// \EntryReg stores the intiial address of an entry
			// which points to the first byte of length quad
			PushStack \EntryReg
			jmp LookUpDone
		NotMatching:
			GoToNextEntry \EntryReg

	jmp ForEachEntry
	LookUpDone:
	
.endm

Find:
	FindEntry %r13
	ret