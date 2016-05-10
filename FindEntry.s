

.macro GoToNextEntry EntryReg

    subq (\EntryReg), \EntryReg
    movq -8(\EntryReg), \EntryReg
    GoToEntry \EntryReg
    
.endm

.macro GoToFirstEntry EntryReg

    movq -8(\EntryReg), \EntryReg
    GoToEntry \EntryReg

.endm

.macro GoToEntry EntryReg
    leaq DictEnd(%rip), %r10
    leaq (%r10, \EntryReg), \EntryReg
.endm


.macro FindEntry EntryReg

    leaq DictStart(%rip), \EntryReg
    GoToFirstEntry \EntryReg
    
    ForEachEntry:
        
        cmpq $(0x0), (\EntryReg)
        je LookUpDone

        jmp *\EntryReg
        
        MatchDone:
            jne NotMatching

        Matching:
            leaq 8(\EntryReg), %r10
            PushStack %r10
            jmp LookUpDone
        
        NotMatching:
            GoToNextEntry \EntryReg

        jmp ForEachEntry
    LookUpDone:
    
.endm

Find:
    FindEntry %r13
    ret
