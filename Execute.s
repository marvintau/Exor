
# EXECUTE
# ====================
# This part mainly manipulates the entering and exiting
# words that consist of either executable code or other
# words. This could be the most interesting and tricky
# part in the whole project. Have fun in reading!


# EXECUTE NEXT WORD
# ===================
# %r12 stores the address pointing to a quad that points
# to another word. So we may jump into that code through
# indirect jumping. And the destination should be always
# an executable instruction.

# If we just have the %r12 stores the address that about
# jump to, then there is no need to use indirect jumping,
# (the parentheses). If we are going to use it, %r12 has
# to POINT TO ANOTHER ADDRESS TO JUMP TO. (Ponder it!)

# And you are right. %r12 is never points to an address
# that you can jump to and execute, but a quad pointing
# to another piece of code. If the entry has executable 
# code, then this quad should be the starting address of
# the code. If the entry is a word that contains other
# words, then this should be EnterWord.

.macro ExecuteNextWord

    movq  (%r13), %r12
    leaq 8(%r13), %r13 
    jmpq *(%r12)

.endm

# ENTERWORD
# =====================
# Voila! EnterWord does is the final destination of the
# jumping, and EnterWord will be executed right after we
# enter EACH word, no matter it contains instructions or
# other word address.

# Remember the r12 still stores the quad that points to
# the address of EnterWord, r12 will be pointing to the
# next address, either another entry or executable code.

# Next up, r13 is assigned with r12 too. Combining with
# the first instruction of ExecuteNextWord, and discard
# the operation over r13, we will have
#
# leaq 8(%r12), %r12
# movq  (%r12), %r12
# jmpq *(%r12)
#
# That pretty explains how do we enter the body of the
# entry.

EnterWord:
    PushStack %r13
    leaq 8(%r12), %r12
    movq   %r12,  %r13
    ExecuteNextWord

# EXITWORD
# =======================


ExitWord:
    PopStack %r13 
    ExecuteNextWord

StartExecution:
    PopStack %r13
    leaq -8(%r13), %r13
    ExecuteNextWord
        
ExitExecution:
    jmp ExecuteDone

   
