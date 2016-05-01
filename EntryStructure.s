.macro String name, content
	Length\name:
		.quad(End\name - \name)
	\name:
		.ascii "\content"
	End\name:
.endm

.macro Entry name, EntryType

	// This name is particularly for defining words
	// before compile-time, i.e. for built-in words.
	\name:

	jmp EntryCheck\name
		String Entry\name, "\name"

	EntryCheck\name:
		// This will be executed before pushing the reg
		// into stack. Since the Find & Match will push
		// %r13 onto the stack, we always use %r13 here.
		leaq Entry\name(%rip), %r13
		call MatchWord

		// %r13 is free to modified. Here we are going
		// to use %r13 as the entry pointer and pass it
		// back to the matching subroutine.
		leaq EntryBegin\name(%rip), %r13
		jmp  MatchDone

	EntryBegin\name:
		// Notably, EntryCheck may have a different way
		// to check the name pattern. We only care about
		// the ZF register when jumped to MatchDone. If
		// the pattern is not matching, we need to jump
		// back to the beginning of the entry with the
		// following distance indicated by the first 8
		// bytes. Otherwise, the IP will jump 16 bytes
		// further from this address in order to execute
		// the actual code.

		.quad (EntryBegin\name - \name)
		.quad \EntryType
.endm

.macro EntryEnd name
	EntryEndOf\name:
		.quad (\name - DictEnd)
.endm

.macro StringDisplay name, string
	Entry \name, EntryType.Code
		jmp SkippedContent\name
			String Content\name, "\string"
		SkippedContent\name:
			push %r13
			leaq Content\name(%rip), %r13
			call PrintString
			pop  %r13
			jmp ExecuteDone
	EntryEnd \name
.endm