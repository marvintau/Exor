
# ENTRY TRAVERSING ROUTINES
# =========================
# also execlusively used by FindEntry

.macro GoToEntry EntryReg
    leaq DictEnd(%rip), %r10
    leaq (%r10, \EntryReg), \EntryReg
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
    leaq 8(\EntryReg), \EntryReg
.endm

Code CheckEnd
    xorq %rax, %rax
    cmpq $(0x0), (%r11)
    sete %al
    shlq %rax
    PushDataStack %rax
CodeEnd CheckEnd

Code EvaluateEntry

    push %r11 
    GoToDefinition %r11 
    
    jmp ExecuteLexedWord 
    EvaluateDone:
        PopStack %r13
    pop %r11 

CodeEnd EvaluateEntry

Code ReturnLexer 
    .quad RealReturnLexer
RealReturnLexer:
    jmp EvaluateDone 
CodeEnd ReturnLexer

Code MatchName
    xorq %rax, %rax
    MatchExactName %r11
    setne %al
    PushDataStack %rax
CodeEnd MatchName

Code EnterEntry
    leaq DictStart(%rip), %r11 
    GoToNextEntry %r11
CodeEnd EnterEntry

Code NextEntry
    GoToNextEntry %r11
CodeEnd NextEntry

Word ParseWord
    .quad EnterEntry
    .quad Find
WordEnd ParseWord

Word Find
    .quad CheckEnd
    .quad Cond
    .quad MatchAndEval
    .quad LoopLikeForever
WordEnd Find

Word MatchAndEval
    .quad MatchName
    .quad Cond
    .quad EvaluateEntry
    .quad NextEntry
WordEnd MatchAndEval


