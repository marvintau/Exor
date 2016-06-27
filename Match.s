# ENTRY NAME MATCHING
# ===================
# exclusively used by FindEntry.

.macro MatchLen LenReg, EntryReg, DoneLabel

    movq \LenReg, %rcx
    cmpq (\EntryReg), %rcx
    jne \DoneLabel

.endm

.macro MatchChar BuffReg, EntryReg, DoneLabel
    ForEachCharacter:		
        movb  -1(\BuffReg, %rcx), %al
        cmpb  7(\EntryReg, %rcx), %al
        jne \DoneLabel
    loop ForEachCharacter
.endm

.macro MatchNumber BuffReg, LenReg

    movq \LenReg, %rcx
    xorq %rax, %rax

    ForEachDigit:
        movb -1(\BuffReg, %rcx), %al
        cmpb $0x61, %al
        jl NotHex
        cmpb $0x66, %al
        jg NotHex

        movq $1, %rax
        jmp IsDigit

        NotHex:
            cmpb $0x30, %al
            jl NotEvenDigit
            cmpb $0x39, %al
            jg NotEvenDigit
            
            jmp IsDigit

        NotEvenDigit:
            movq $2, %rax
            jmp MatchNumberDone 

        IsDigit:

    loop ForEachDigit
    MatchNumberDone:
.endm

.macro MatchExactName EntryReg

    MatchLen %r9, \EntryReg, MatchExactNameDone
    MatchChar %r8, \EntryReg, MatchExactNameDone
    MatchExactNameDone:

.endm

