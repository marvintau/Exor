
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

# DEFINE LITERAL
# ==============
# Defines an empty entry, while the entry name field can be used to
# store arbitrary ASCII information. All of parsed and unknown (not
# in the dictionary) string from input buffer will be stored as
# literal.

Word DefineLiteral
    .quad AddEntryHeader
    .quad AddEntryEnd
WordEnd DefineLiteral

# ADD WORD
# ==============
# Add a new word address to the current entry. It reads the current
# Dictionary Start Address, and the offset from Dictionary Start
# Address, to the last written address, write the new word address
# at this address, and save the current offset for future use.
Code AddWord
    push %rax
    push %rbx
    push %rdx

    movq DictionaryStartAddress(%rip), %rdx
    PopDataStack %rax
    movq %r11, (%rdx, %rax)
    addq $(0x8), %rax
    PushDataStack %rax

    pop  %rdx
    pop  %rbx
    pop  %rax
CodeEnd AddWord 

Code ClearBuffer
    movq $(0x20), %rax
    movq $(0x40), %rcx
    movq InputBuffer(%rip), %rsi
    rep stosq
CodeEnd ClearBuffer

# COMPILE
# ==============-
# Compile tries to translate the word sequence in the buffer into
# a series of entry address, 
Word Compile
    
WordEnd Compile

Code RemoveLastEntry
    push %rax
    movq DictionaryStartAddress(%rip), %rax
    GoToNextEntry %rax
    movq %rax, DictionaryStartAddress(%rip)    
    pop %rax
CodeEnd RemoveLastEntry



