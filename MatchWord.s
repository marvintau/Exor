# Compare two strings. First check if the strings have equal
# length, then check if any different char exists. The piece
# of code doesn't affected the referred address registers
# except the counter.

.macro MatchLen BuffReg, EntryReg, DoneLabel
    movq -8(\BuffReg), %rcx
    cmpq -8(\EntryReg), %rcx
    jne \DoneLabel

.endm

.macro MatchChar BuffReg, EntryReg, DoneLabel
    movq (\BuffReg), \BuffReg
    ForEachCharacter:		
        movb -1(\BuffReg, %rcx), %al
        cmpb -1(\EntryReg, %rcx), %al
        jne \DoneLabel
    loop ForEachCharacter
.endm

.macro MatchExactName EntryReg

    push %r14
    push %rcx

    leaq WordOffset(%rip), %r14

    MatchLen %r14, \EntryReg, MatchExactNameDone
    MatchChar %r14, \EntryReg, MatchExactNameDone
    MatchExactNameDone:

    pop %rcx
    pop %r14

.endm

.macro MatchInteger BuffReg, ResReg, DoneLabel
        
    xorq \ResReg, \ResReg
    incq \ResReg
    BeforeMoving:
    movq (\BuffReg), \BuffReg
    ForEachDigit:
	cmpb $(0x30), -1(\BuffReg, %rcx)
	jl \DoneLabel
	cmpb $(0x39), -1(\BuffReg, %rcx)
	jg \DoneLabel
    loop ForEachDigit

    decq \ResReg

.endm

MatchExactName:
    MatchExactName %r13
    ret

MatchInteger:

    push %r14
    push %r13
    push %rcx

    leaq WordOffset(%rip), %r14
    MatchInteger %r14, %r13, MatchIntegerDone
    MatchIntegerDone:

    pop  %rcx
    pop  %r13
    pop  %r14
    ret


