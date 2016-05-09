
# All entry matching functions are here. Note that 
# the comparison needs the two registers containing
# the buffer offset and length.

# consider to make a set of macro set definitions to
# replace the register with more comprehensible name.

.macro MatchLen LenReg, EntryReg, DoneLabel
    movq \LenReg, %rcx
    cmpq -8(\EntryReg), %rcx
    jne \DoneLabel

.endm

.macro MatchChar BuffReg, EntryReg, DoneLabel
    ForEachCharacter:		
        movb -1(\BuffReg, %rcx), %al
        cmpb -1(\EntryReg, %rcx), %al
        jne \DoneLabel
    loop ForEachCharacter
.endm

.macro MatchExactName EntryReg

    MatchLen %r8, \EntryReg, MatchExactNameDone
    MatchChar %r9, \EntryReg, MatchExactNameDone
    MatchExactNameDone:

.endm

.macro MatchInteger BuffReg, ResReg, DoneLabel
        
    xorq \ResReg, \ResReg
    incq \ResReg
    BeforeMoving:
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

    MatchInteger %r9, %r13, MatchIntegerDone
    MatchIntegerDone:

    ret


