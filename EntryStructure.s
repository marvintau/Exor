
# STRING MACRO
# ======================
# Char array with length

.macro String name, content
	Length\name:
		.quad(End\name - \name)
	\name:
		.ascii "\content"
	End\name:
.endm

# ENTRY HEADER
# ====================
# Contains merely a string indicating the name.

.macro EntryHeader name

    Header\name:
        String Entry\name, "\name"
    \name:

.endm

# ENTRY END
# ====================
# The quad following the label stores the offset from the dictionary end
# (DictEnd) to current entry header. The data contained in this macro is
# actually a part of next entry, used as the link to its previous entry.

.macro EntryEnd name

    EntryEndOf\name:
	.quad (Header\name - DictEnd)

.endm

# CODE ENTRY & WORD ENTRY
# =======================
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
    ExecuteNextWord
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

.macro StringDisplay name, string
    Code Sub\name

        jmp SkippedContent\name
            String Content\name, "\string"
        SkippedContent\name:
            push %r15
            leaq Content\name(%rip), %r15
	    Print %r15, -8(%r15)
            pop  %r15       

            ExecuteNextWord %r12
     
    CodeEnd Sub\name

    Word \name
        .quad Sub\name
    WordEnd \name
.endm

