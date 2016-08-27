
# ENTRY TRAVERSING ROUTINES
# =========================
# also execlusively used by FindEntry

.macro GoToEntry EntryReg
    push %r10
    leaq DictEnd(%rip), %r10
    leaq (%r10, \EntryReg), \EntryReg
    pop %r10
.endm

.macro GoToNextEntry EntryReg
    movq -8(\EntryReg), \EntryReg
    GoToEntry \EntryReg
.endm

# Let EntryReg stores the address of definition.
# The offset depends on the content between the
# header label and content label.

.macro GoToDefinition EntryReg
    addq (\EntryReg), \EntryReg
    leaq 16(\EntryReg), \EntryReg
.endm

# ==============================================
# MATCH INPUT NAME WITH DICTIONARY
# ==============================================
# Compare the user input stored in buffer, located
# by %r8 the address and %r9 the length, against
# the entry name from %r11

Code MatchName
    
    xorq %rax, %rax
    
    # ------------------------------------------
    # COMPARE LENGTH
    
    movq %r9, %rcx
    cmpq (%r11), %rcx
    jne MatchExactNameDone 

    # ------------------------------------------
    # COMPARE EACH CHARACTER
    
    ForEachCharacter:		
        movb  -1(%r8, %rcx), %al
        cmpb  7(%r11, %rcx), %al
        jne MatchExactNameDone 
    loop ForEachCharacter

    # ------------------------------------------
    # STORE COMPARISON RESULT

    MatchExactNameDone:
        setne %al

        # 3 for the offset between Cond after MatchName
        # and NextEntry
        imulq $(2), %rax

        # For Cond
        push %rax

CodeEnd MatchName

Code EnterEntry
    movq DictionaryStartAddress(%rip), %r11 
    GoToNextEntry %r11
CodeEnd EnterEntry

Code NextEntry
    GoToNextEntry %r11
CodeEnd NextEntry

Code EndNotReached

    xorq %rax, %rax
    cmpq $(0x0), (%r11)
    setne %al

    # for LoopWhile
    push %rax
CodeEnd EndNotReached

Word FindIteration
    .quad MatchName
    .quad Cond
    .quad Eval
    .quad Cond 
    .quad NextEntry
    .quad EndNotReached 
    .quad LoopWhile
    .quad DefineLiteral
WordEnd FindIteration

Word ParseWord
    .quad EnterEntry
    .quad FindIteration
WordEnd ParseWord

Code PrintEntryName
    jmp PrintCode
NewlineString:
    .asciz "\n"
PrintCode:

    pushq   %rsi
    pushq   %rdx
    pushq   %r11

    movq    $SyscallDisplay, %rax
    movq    $1, %rdi
    movq    $1, %rbx
    leaq    8(%r11), %rsi
    movq    (%r11), %rdx
    syscall
	
    movq    $SyscallDisplay, %rax
    movq    $1, %rdi
    movq    $1, %rbx
    leaq    NewlineString(%rip), %rsi
    movq    $1, %rdx
    syscall

    popq    %r11
    popq    %rdx
    popq    %rsi


CodeEnd PrintEntryName

Word PrintAndMove
    .quad PrintEntryName
    .quad NextEntry
WordEnd PrintAndMove

Word PrintEntryNameIteration
    .quad PrintAndMove
    .quad EndNotReached
    .quad LoopWhile
WordEnd PrintEntryNameIteration

Word PrintEntryNames
    .quad EnterEntry
    .quad PrintEntryNameIteration
WordEnd PrintEntryNames

