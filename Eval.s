# ======================================================
# EVAL
# ======================================================
# Save the current runtime context and go to the routine
# defined by user words. No registers are preserved, but
# guaranteed to lead the instruction pointer back.

Code Eval
    
    # For debugging
    incq EvaluationLevel(%rip)

    # Save context and prepare to jump to the new
    # session
    movq %r11, %r12
    GoToDefinition %r12
    PushStack %r13
    leaq ReturnAddress(%rip), %r13
    
    jmp *(%r12)

    # -------------LEFT CURRENT SESSION-----------------

    EvaluateDone:
        decq EvaluationLevel(%rip)
        PopStack %r13

    # 4 for the distance between Cond and DefineLiteral 
    movq $(4), %rax
    # leave this to Cond
    push %rax


CodeEnd Eval

# ======================================================
# RETURN
# ======================================================
# A word that merely referred by Eval, that guide the
# instruction pointer back to the code starting from
# EvaluateDone in Eval.
Code Return 
    jmp EvaluateDone 
ReturnAddress:
    .quad Return
CodeEnd Return
