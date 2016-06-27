.include "Match.s"

# Lexer uses r8 and r9 register

# Always terminates when a bigram of char followed with
# a space is found, with StartReg pointing to initial,
# and EndReg to first space after last char. 

.macro LocateWordBound StartReg, EndReg 

    leaq InputBuffer(%rip), %rax 

    NextBigram:
        cmpq \StartReg, %rax 
        je   WordLocated

        cmpb $(0x20), (\StartReg)
        je   StartWithSpace
        jne  StartWithChar

        StartWithSpace:
            xorq \EndReg, \EndReg
            cmpb $(0x20), -1(\StartReg)
            je  MoveCurr 

            CharNext:
                movq \StartReg, \EndReg
                jmp MoveCurr 

        StartWithChar:
            cmpb $(0x20), -1(\StartReg) 
            jne MoveCurr 

            SpaceNext:

                jmp WordLocated

        MoveCurr:

            decq \StartReg
        
        jmp NextBigram 

    WordLocated:

.endm

.macro AreWeDone StartReg, EndReg, LoopLabel, DoneLabel

    leaq InputBuffer(%rip), \EndReg
    cmpq \StartReg, \EndReg
    je   \DoneLabel
    
    decq \StartReg
    jmp  \LoopLabel
.endm

.macro ParseDecimal StartReg, LenReg

    xorq  %rax, %rax
    xorq  %rbx, %rbx
    xorq  %rcx, %rcx

    ParseDecimalForEachDigit:
        imul $10, %rax
        
        movzbq (\StartReg, %rcx), %rbx
        subq $0x30, %rbx
        addq %rbx, %rax 
        
        incq %rcx
        cmpq %rcx, \LenReg

        jne ParseDecimalForEachDigit
CheckRax:

    PushDataStack %rax

.endm

.macro ParseHex StartReg, LenReg

    xorq  %rax, %rax
    xorq  %rbx, %rbx
    xorq  %rcx, %rcx

    ParseHexForEachDigit:
        imul $0x10, %rax
        
        movzbq (\StartReg, %rcx), %rbx
        cmpb $0x60,  %bl
        jg Hex
            subq $0x30, %rbx
            jmp ParseHexCheckDone
        Hex:
            subq $0x57, %rbx

        ParseHexCheckDone:
        
        addq %rbx, %rax 
        
        incq %rcx
        cmpq %rcx, \LenReg

        jne ParseHexForEachDigit

    PushDataStack %rax

.endm


