
# GoToNextEntry is exclusively used in FindEntry.
.macro GoToNextEntry EntryReg

    # move from the entry beginning 
    subq (\EntryReg), \EntryReg
    movq -8(\EntryReg), \EntryReg

    # By far the EntryReg is storing the offset from
    # the Dictionary head to PREVIOUS entry.
    leaq DictEnd(%rip), %r10
    leaq (%r10, \EntryReg), \EntryReg
.endm

.macro GoToFirstEntry EntryReg

    # Slightly different from GoToNextEntry, at first
    # the \EntryReg is not pointing to something like
    # entry beginning. Thus we just move 8 bytes back
    # and perform the exactly same thing.
    movq -8(\EntryReg), \EntryReg
    leaq DictEnd(%rip), %r10
    leaq (%r10, \EntryReg), \EntryReg    
.endm

# This is particularly used in PopStack, for jump to entry
# with given entry address.
.macro GoToEntry EntryReg
    leaq DictEnd(%rip, \EntryReg), %r10
    leaq (%r10, \EntryReg), \EntryReg
.endm


.macro FindEntry EntryReg

    # Initialize the dictionary pointer registers.
    leaq DictStart(%rip), \EntryReg
    GoToFirstEntry \EntryReg
    
    ForEachEntry:
        # Check if dictionary end reached
        cmpq $(0x0), (\EntryReg)
        je LookUpDone

        # Jump to entry-defined matching subroutine.
        # Matching subroutine has to return to MatchDone
        jmp *\EntryReg
        MatchDone:
            jne NotMatching

        Matching:
            # SANITY CHECK:
            # Now \EntryReg stores the EntryBegin\name,
            # or the address of the beginning of the
            # code. 
            PushStack \EntryReg
            jmp LookUpDone
        NotMatching:
            GoToNextEntry \EntryReg

    jmp ForEachEntry
    LookUpDone:
    
.endm

Find:
    FindEntry %r13
    ret
