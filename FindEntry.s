
# ENTRY TRAVERSING ROUTINES
# =========================
# also execlusively used by FindEntry

.macro GoToFirstEntry EntryReg
    leaq DictStart(%rip), \EntryReg
    GoToNextEntry \EntryReg
.endm

.macro GoToNextEntry EntryReg

    movq -8(\EntryReg), \EntryReg
    GoToEntry \EntryReg
    
.endm

.macro GoToEntry EntryReg
    leaq DictEnd(%rip), %r10
    leaq (%r10, \EntryReg), \EntryReg
.endm

# Let EntryReg stores the address of definition.
# The offset depends on the content between the
# header label and content label.

.macro GoToDefinition EntryReg
    addq (\EntryReg), \EntryReg
    leaq 8(\EntryReg), \EntryReg
.endm

.macro FindEntry EntryReg

    GoToFirstEntry \EntryReg   
 
    ForEachEntry:
        
        cmpq $(0x0), (\EntryReg)
        je LookUpDone

        MatchExactName \EntryReg       
 
            jne NotMatching

        OtherwiseMatching:
           
            push \EntryReg 

                GoToDefinition \EntryReg

                jmp ExecuteLexedWord 

                ExecutionDone:
                    # since we pushed the r13 onto stack
                    # when entering ExecuteLexedWord
                    PopStack %r13

            pop  \EntryReg
            jmp LookUpDone
        
        NotMatching:
            GoToNextEntry \EntryReg

        jmp ForEachEntry
    LookUpDone:
    
.endm
