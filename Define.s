
# AddEntryEnd is exclusively used by creating new Entry.

Code AddEntryEnd 
    push %rax
    push %rbx
    push %rcx

    # The word before ExpandDictionaryLength should push the
    # length of expansion onto the stack.
    PopDataStack %rax

    movq DictionaryStartAddress(%rip), %rbx
    leaq DictEnd(%rip), %rcx
   
    # EntryEnd stores the offset between the header address of
    # CURRENT Entry and Dictionary End, or the distance between
    # the current DictionaryStartAddress and Dictionary End. So
    # now %rbx is holding the content to be stored on EntryEnd
    subq %rcx, %rbx

    # Now get the new DictionaryStartAddress and store on %rcx,
    # and store the link to proper address.
    movq DictionaryStartAddress(%rip), %rcx

    # Get the new DictionaryStartAddress and store into %rcx,
    # an extra 8-byte offset is made for storing the EntryEnd,
    # which used for locating the next entry on dictionary.
    leaq 8(%rcx, %rax), %rcx
    movq %rbx, -8(%rcx)

    # Finally, update the new DictionaryStartAddress in
    # memory.
    movq %rcx, DictionaryStartAddress(%rip)


    pop  %rcx
    pop  %rbx
    pop  %rax
CodeEnd AddEntryEnd 

# AddEntryHeader is supposed to be handling the user input, thus
# it uses the buffer slice registers directly. Remember r8 denotes
# the starting address of the slice in the buffer, while r9 the
# length of the slice.

Code AddEntryHeader
    push %r8
    push %r9
    push %rax
    push %rbx
    push %rcx

    # put the string length first
    movq DictionaryStartAddress(%rip), %rbx
    movq %r9, %rcx
    movq %rcx, (%rbx) 

    # then each byte of the string
    NextChar:
        movb -1(%r8, %rcx), %al
        movb %al, 7(%rbx, %rcx)
        loop NextChar    


    # restore the original length
    movq %r9, %rcx

    # put another offset right after the string. 7 because
    # rcx was not decreased to 0.
    addq $(8), %rcx
    movq %rcx, (%rbx, %rcx)
    addq $(8), %rcx   

    PushDataStack %rcx

    pop %rcx
    pop %rbx
    pop %rax
    pop %r9
    pop %r8
CodeEnd AddEntryHeader

# VALIDATION:
# This function should be put in word Find, and executed when no existing
# word is found, then perform PrintEntryNames before exiting.

Word AddLiteral
    .quad AddEntryHeader
    .quad AddEntryEnd
WordEnd AddLiteral


Code RemoveLastEntry
    push %rax
    movq DictionaryStartAddress(%rip), %rax
    GoToNextEntry %rax
    movq %rax, DictionaryStartAddress(%rip)    
    pop %rax
CodeEnd RemoveLastEntry
