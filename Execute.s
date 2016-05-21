
# EXECUTE
# ====================
# After lexing and parsing stage, no registers
# are still occupied, since all info regarding 
# words are stored on stack. 

# It needs two registers to perfrom the jumping
# between the caller and callee words, and the
# successive words.

# When we finish the current word, we need to
# remember where we entered this word from, and
# find the entrance of the next word with that
# address. Assuming that the calling pointer is
# %r13, and the called pointer is %r12, we have:

.macro ExecuteNextWord

    movq  (%r13), %r12
    leaq 8(%r12), %r12 
    jmpq *(%r12)

.endm


# ENTERWORD
# =====================
# EnterWord should be always placed at the very
# beginning of each word, because each time the
# "jmpq *(%r12)" will always lead the instruction
# goes here.

EnterWord:
    PushStack %r13
    leaq 8(%r12), %r12
    movq   %r12,  %r13
    ExecuteNextWord

ExitWord:
    PopStack %r13 
    ExecuteNextWord

StartExecution:
    PopStack %r13
    leaq -8(%r13), %r13
    ExecuteNextWord
        
ExitExecution:
    jmp ExecuteDone    
