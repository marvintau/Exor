# EvaluateEntry will be playing the role as exec,
# eval or similar functions in most of the main-
# stream dynamic interpreting language. Evaluate-
# Entry should returns to the calling point after
# evaluate the new entry. Since EvaluateEntry will
# break the normal traversing of evaluation tree,
# A dedicated stack should be created for this
# code word. 

Word Eval
    .quad PushEntryReg
    .quad EvalCore
    .quad PopEntryReg
WordEnd Eval

Code PushEntryReg
    push %r11
    GoToDefinition %r11 
CodeEnd PushEntryReg

Code PopEntryReg
    pop %r11
CodeEnd PopEntryReg

# The real eval routine extracted from evalEntry.
# %r11 will be the destination entry.
Code EvalCore

    movq %r11, %r12
    PushStack %r13

    incq EvaluationLevel(%rip)
    
    leaq ReturnAddress(%rip), %r13

    jmp *(%r12)

    EvaluateDone:
        decq EvaluationLevel(%rip)
        PopStack %r13

CodeEnd EvalCore

# ReturnLexer will be automatically pushed into
# the return stack of the word being evaluated,
# coerced to return to the evaluating point.

Code ReturnLexer 
    jmp EvaluateDone 
ReturnAddress:
    .quad ReturnLexer
CodeEnd ReturnLexer

# Before adding new entry to memory, we suppose that
# we have get the new word bound. Thus AddEntryHeader
# should be called in another word with LocateWordBound
# called right before.

# Note that after the LocateWordBound being called, the
# register EndReg (%r9) remains same, yet StartReg (%r8)
# stores the length of the string.

Code AddEntryHeader    
    push %rax
    push %rcx
    
    

    pop  %rcx
    pop  %rax
CodeEnd AddEntryHeader

Code AddEntryEnd
CodeEnd AddEntryEnd
