
# ENTRY NAME MATCHING
# ===================
# exclusively used by FindEntry.

.macro MatchLen LenReg, EntryReg, DoneLabel

    movq \LenReg, %rcx
    incq %rcx
    cmpq (\EntryReg), %rcx
    jne \DoneLabel

.endm

.macro MatchChar BuffReg, EntryReg, DoneLabel
    ForEachCharacter:		
        movb  -1(\BuffReg, %rcx), %al
        cmpb  7(\EntryReg, %rcx), %al
        jne \DoneLabel
    loop ForEachCharacter
.endm

.macro MatchExactName EntryReg

    
    MatchLen %r8, \EntryReg, MatchExactNameDone
    MatchChar %r9, \EntryReg, MatchExactNameDone
    MatchExactNameDone:

   # decq %r8

.endm

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
            PushStack \EntryReg 
            pop  \EntryReg
            jmp LookUpDone
        
        NotMatching:
            GoToNextEntry \EntryReg

        jmp ForEachEntry
    LookUpDone:
    
.endm

Find:
    FindEntry %r13
    ret
