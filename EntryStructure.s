
# =========================================================================
# ENTRY STRUCTURE
# =========================================================================
# EntryStructure.s contains a lot of macros. A macro definition contains a
# name, and arguments, and a piece of code. The name that refer to macro
# definition will be replaced by the corresponding code during assembling.
# Consequently, macro definition won't be appearing in the final binary.

# STRING MACRO
# ======================
# Char array with length

.macro String name, content
	Length\name:
		.quad (End\name - \name)
	\name:
		.ascii "\content"
	End\name:
.endm

# =========================================================================
# ENTRY HEADER
# =========================================================================
# Contains merely a string indicating the name. The quad after the string
# indicates the distance between the actual entry entering point and the
# header of the entry.

.macro EntryHeader name

    Header\name:
        String Entry\name, "\name"
        .quad (\name - Header\name)
    \name:

.endm

# =========================================================================
# ENTRY END
# =========================================================================
# The quad following the label stores the offset from the dictionary end
# (DictEnd) to current entry header. The data contained in this macro is
# actually a part of next entry, used as the link to its previous entry.

.macro EntryEnd name

    EntryEndOf\name:
	.quad (Header\name - DictEnd)

.endm

# =========================================================================
# CODE ENTRY & WORD ENTRY
# =========================================================================
# Both code and word entry extends the EntryHeader with one quad, which
# stores the address of the beginning of excutable code. For code entry,
# it will be the starting address of the following code, while for word
# entry, the address of EnterWord.

# Meanwhile, code entry always end up with ExecuteNextWord, which leads
# to the next word. Thus we include this in CodeEnd macro. Word entry is
# always finished up with ExitWord, a subroutine that leads back to 

.macro Code name
    EntryHeader \name
        .quad ActualCodeOf\name
    ActualCodeOf\name:
.endm

.macro CodeEnd name
    jmp ExecuteNextWord
    EntryEnd \name
.endm

.macro Word name
    EntryHeader \name
        .quad EnterWord
.endm

.macro WordEnd name
    .quad Exit 
    EntryEnd \name 
.endm

# =========================================================================
# ENTRY TRAVERSING ROUTINES
# =========================================================================
# also execlusively used by FindEntry

.macro GoToEntry EntryReg
    push %r10
    leaq DictEnd(%rip), %r10
    leaq (%r10, \EntryReg), \EntryReg
    pop %r10
.endm

.macro GoToNextEntry EntryReg
    movq -8(\EntryReg), \EntryReg
    GoToEntry \EntryReg
.endm

# Let EntryReg stores the address of definition.
# The offset depends on the content between the
# header label and content label.

.macro GoToDefinition EntryReg
    addq (\EntryReg), \EntryReg
    leaq 16(\EntryReg), \EntryReg
.endm


