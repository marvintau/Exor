
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
    leaq 16(\EntryReg), \EntryReg
.endm

Code CheckEnd
    xorq %rax, %rax
    cmpq $(0x0), (%r11)
    sete %al
    shlq %rax
    PushDataStack %rax
CodeEnd CheckEnd


# EvaluateEntry will be playing the role as exec,
# eval or similar functions in most of the main-
# stream dynamic interpreting language. Evaluate-
# Entry should returns to the calling point after
# evaluate the new entry. Since EvaluateEntry will
# break the normal traversing of evaluation tree,
# A dedicated stack should be created for this
# code word. 

Code EvaluateEntry

    push %r11 
    GoToDefinition %r11 
    
    jmp ExecuteLexedWord 
    EvaluateDone:
        PopStack %r13
    pop %r11 

CodeEnd EvaluateEntry

# ReturnLexer will be automatically pushed into
# the return stack of the word being evaluated,
# coerced to return to the evaluating point.

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

Code PrintEntryName
    jmp PrintCode
NewlineString:
    .asciz "\n"
PrintCode:
	pushq   %rdi
	pushq	%rsi
	pushq	%rdx
        pushq   %r11

	movq	$SyscallDisplay, %rax
	movq	$1, %rdi
        movq    $1, %rbx
	leaq	8(%r11), %rsi
	movq	(%r11), %rdx
	syscall
	
	movq	$SyscallDisplay, %rax
	movq	$1, %rdi
        movq    $1, %rbx
	leaq	NewlineString(%rip), %rsi
	movq	$1, %rdx
	syscall
	
        popq    %r11
	popq	%rdx
	popq	%rsi
	popq	%rdi
CodeEnd PrintEntryName

Word PrintAndMove
    .quad PrintEntryName
    .quad NextEntry
WordEnd PrintAndMove

Word PrintEntryNameIteration
    .quad CheckEnd
    .quad Cond
    .quad PrintAndMove
    .quad LoopLikeForever
WordEnd PrintEntryNameIteration

Word PrintEntryNames
    .quad EnterEntry
    .quad PrintEntryNameIteration
WordEnd PrintEntryNames

