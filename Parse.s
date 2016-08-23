.macro InitRegisters
    # Supposing the number literal is just added into the dictionary
    movq DictionaryStartAddress(%rip), %rsi
    GoToNextEntry %rsi

    # Get the length of string
    movq (%rsi), %rcx

    # rax will be storing the final result.
    xor %rax, %rax        
.endm

.macro ParseDone Type
    jmp Done\Type

    # Although not likely to happen, but if the number intended to
    # be read as integer is invalid, we pass deafbeef to rax, and
    # leave it to the next handler. Very rarely deafbeef will mean
    # something important other than error.
    Invalid\Type:
        movq $(0xdeafbeef), %rax

    Done\Type:
        push %rax
.endm

Code ParseUnsignedDec

    InitRegisters   

    UnsignedDecNextChar:
        # Read in character, move forward along the string
        xorq %rbx, %rbx
        movb 8(%rsi), %bl
        inc %rsi

        # Validate the number
        cmp $'0', %bl
        jb  InvalidUnsignedDec
        cmp $'9', %bl
        ja  InvalidUnsignedDec

        # Do the accumulation
        sub $'0', %bl
        imul $(10), %rax
        addq %rbx, %rax
        loop UnsignedDecNextChar
       
    ParseDone UnsignedDec
 
CodeEnd ParseUnsignedDec

Code ParseUnsignedHex
    InitRegisters

    UnsignedHexNextChar:
        # Read in character, move forward along the string
        xorq %rbx, %rbx
        movb 8(%rsi), %bl
        inc %rsi

        # Validate the number
        cmp $'0', %bl
        jb  CheckUpperLetter
        cmp $'9', %bl
        ja  CheckUpperLetter
        sub $'0', %bl
        jmp Accumulate

    CheckUpperLetter:
        cmp $'A', %bl
        jb  CheckLowerLetter 
        cmp $'F', %bl
        ja  CheckLowerLetter 
        sub $'A', %bl
        add $(10), %bl
        jmp Accumulate

    CheckLowerLetter:
        cmp $'a', %bl
        jb  InvalidUnsignedHex
        cmp $'f', %bl
        ja  InvalidUnsignedHex
        sub $'a', %bl
        add $(10), %bl
        jmp Accumulate

    Accumulate:
        # Do the accumulation
        imul $(16), %rax
        addq %rbx, %rax
        loop UnsignedHexNextChar

    ParseDone UnsignedHex
CodeEnd ParseUnsignedHex


Word UnsignedDec
    .quad ParseUnsignedDec
    .quad RemoveLastEntry
WordEnd UnsignedDec

Word UnsignedHex
    .quad ParseUnsignedHex
    .quad RemoveLastEntry
WordEnd UnsignedHex

Code TestInt
        pop %rax
        movq $(0), 0
CodeEnd TestInt
