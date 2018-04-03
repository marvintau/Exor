# ===================================================================
# ADD ENTRY END
# ===================================================================

# AddEntryEnd is exclusively used by creating new Entry.

Code AddEntryEnd 

    # The word before ExpandDictionaryLength should push the
    # length of expansion onto the stack.
    pop %rax

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

CodeEnd AddEntryEnd 

# ===================================================================
# ADD ENTRY HEADER
# ===================================================================

# AddEntryHeader is supposed to be handling the user input, thus
# it uses the buffer slice registers directly. Remember r8 denotes
# the starting address of the slice in the buffer, while r9 the
# length of the slice.

Code AddEntryHeader

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

    push %rcx

CodeEnd AddEntryHeader

# DEFINE LITERAL
# ==============
# Defines an empty entry, while the entry name field can be used to
# store arbitrary ASCII information. All of parsed and unknown (not
# in the dictionary) string from input buffer will be stored as
# literal.

Code IfBufferEndReached

    xorq %rax, %rax
    cmp $(0), %r9
    sete %al
    shl $(1), %al
    push %rax
CodeEnd IfBufferEndReached

Word DefineLiteral
    .quad IfBufferEndReached
    .quad Cond
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

    movq DictionaryStartAddress(%rip), %rdx
    pop %rax
    movq %r11, (%rdx, %rax)
    addq $(0x8), %rax

    push %rax

CodeEnd AddWord 

Code ClearBuffer
    movq $(0x20), %rax
    movq $(0x1), %rcx
    leaq InputBuffer(%rip), %rdi
    rep stosw
CodeEnd ClearBuffer

# DEFINE
# ==============-
# Define tries to translate the word sequence in the buffer into
# a series of entry address. It would clear the buffer and start
# a new session. In the new session, all user input will be lexed
# and recognized as words with AddWord, and a new word will be
# formed.
Word Define
    .quad ClearBuffer
    .quad ScanInputBuffer
    .quad EnterEntry
    .quad Rewind
    .quad Compile
WordEnd Define

# REWIND
# ==============
# goes back to the starting position of newly added entry, and 
# rewrite with referred word addresses, and finally add the entry
# end. Since the Entry end needs the entry length and address,
# we have to preserve the entry address until the entry end is
# calculated.

# Since we prohibit using registers without popping from stack,
# we have to save how many words we have written right after the
# word address we added. The code word that writes new address
# will read the numbers first, save it to a spare register, and
# overwrite the quadword with new address, and then append the
# number after the newly added addres by increasing 1. Thus it
# should be initiated with 0, by overwritting current EntryEnd.

Code Rewind
    movq DictionaryStartAddress(%rip), %rax
    GoToNextEntry %rax
    GoToDefinition %rax
    movq $(0), -8(%rax)
CodeEnd Rewind

Word Compile
    .quad LocateWordBound
    .quad CompileFind
    .quad BufferEndNotReached_LoopWhile 
    .quad LoopWhile
WordEnd Compile

Word CompileFind
    .quad MatchName_Branch
    .quad StoreAddress 
    .quad NextEntry
    .quad EndNotReached_LoopWhile 
    .quad LoopWhile
 WordEnd CompileFind

Code StoreAddress
    
    movq DictionaryStartAddress(%rip), %rax
    GoToDefinition %rax
    movq -8(%rax), %rbx
    leaq (%rax, %rbx), %rbx

    # Now %rbx is the address to be written with new word
CodeEnd StoreAddress

Code RemoveLastEntry
    movq DictionaryStartAddress(%rip), %rax
    GoToNextEntry %rax
    movq %rax, DictionaryStartAddress(%rip)    
CodeEnd RemoveLastEntry



