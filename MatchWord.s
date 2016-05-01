# Compare two strings. First check if the strings have equal
# length, then check if any different char exists. The piece
# of code doesn't affected the referred address registers
# except the counter.

.macro CompareLen BuffReg, EntryReg, DoneLabel
	movq -8(\BuffReg), %rcx
	cmpq -8(\EntryReg), %rcx
	jne \DoneLabel

.endm

.macro CompareChar BuffReg, EntryReg, DoneLabel
	movq (\BuffReg), \BuffReg
	ForEachCharacter:		
		movb -1(\BuffReg, %rcx), %al
		cmpb -1(\EntryReg, %rcx), %al
		jne \DoneLabel
	loop ForEachCharacter
.endm

.macro CheckNumber BuffReg, DoneLabel
	movq (\BuffReg), \BuffReg
	ForEachDigit:
		cmpb $(0x30), -1(\BuffReg, %rcx)
		jl \DoneLabel
		cmpb $(0x39), -1(\BuffReg, %rcx)
		jg \DoneLabel
	loop ForEachDigit
.endm

.macro Compare EntryReg

	push %r14
	push %rcx

	leaq WordOffset(%rip), %r14

	CompareLen %r14, \EntryReg, CompareDone
	CompareChar %r14, \EntryReg, CompareDone
	CompareDone:

	pop %rcx
	pop %r14

.endm

MatchWord:
	Compare %r13
	ret
