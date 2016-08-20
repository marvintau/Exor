Code Int
    push    %rax
    push    %rbx        # preserve working registers
    push    %rdx
    push    %rsi
    push    %rcx

    # Supposing the number literal is just added into the dictionary
    movq DictionaryStartAddress(%rip), %rsi
    GoToNextEntry %rsi

    # Get the length of string
    movq (%rsi), %rcx

    # rax will be storing the final result.
    xor %rax, %rax        
    
    IntNextChar:
        # Read in character, move forward along the string
        xorq %rbx, %rbx
        movb 8(%rsi), %bl
        inc %rsi

        # Validate the number
        cmp $'0', %bl
        jb  Invalid
        cmp $'9', %bl
        ja  Invalid

        # Do the accumulation
        sub $'0', %bl
        imul $(10), %rax
        addq %rbx, %rax
        loop IntNextChar
        
    jmp IntDone

    # Although not likely to happen, but if the number intended to
    # be read as integer is invalid, we pass deafbeef to rax, and
    # leave it to the next handler. Very rarely deafbeef will mean
    # something important other than error.
    Invalid:
        movq $(0xdeafbeef), %rax

    IntDone:
        PushDataStack %rax

        pop %rcx
        pop  %rsi            # recover saved registers
        pop  %rdx
        pop  %rbx
        pop  %rax
CodeEnd Int

Code TestInt
    push %rax
        PopDataStack %rax
        movq $(0), 0
    pop %rax
CodeEnd TestInt
