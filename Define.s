
# ExpandDictionaryLength is exclusively used by creating
# new Entry. A malformed expansion will definitely destroy
# the dictionary.

# Notably, a 8-byte field BEFORE the new DictionaryStartAddress
# stores the offset from the offset to the Dictionary End, thus
# this length should be count when calculating the whole entry
# length 
Code ExpandDictionaryLength
    push %rax
    push %rbx
    push %rcx

    # Last word before ExpandDictionaryLength should
    # push the expanding length onto the stack.
    PopDataStack %rax

    movq DictionaryStartAddress(%rip), %rbx
    movq DictEnd(%rip), %rcx

    # Get the new DictionaryStartAddress, and calcuate
    # the offset from Dictionary End.
    leaq (%rbx, %rax), %rbx
    movq %rbx, -8(%rbx)
    subq %rcx, -8(%rbx)

    # Finally, update the new DictionaryStartAddress in
    # memory.
    movq %rbx, DictionaryStartAddress(%rip)

    pop  %rcx
    pop  %rbx
    pop  %rax
CodeEnd ExpandDictionaryLength

Code RemoveLastEntry
    push %rax
    movq DictionaryStartAddress(%rip), %rax
    GoToNextEntry %rax
    movq %rax, DictionaryStartAddress(%rip)    
    pop %rax
CodeEnd RemoveLastEntry
