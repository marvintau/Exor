
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

# CONDITIONAL BRANCHING WORD
# =======================
# Forth has its own version of branching, the conditional branching word
# is merely for the convenience of writing built-in words. We employ the
# EnterSpecificWord subroutine, which is handy for implementing if-then
# and switch-case mechanism.

# And of course, you have to write .Exit right after each word you want
# to execute, just the break in each case of a switch-case block.

# And by the way, the ConditionalWord uses same end as ordinary word.

.macro ConditionalWord name
    EntryHeader \name
        .quad EnterSpecificWord
.endm


# LOOPING WORD
# ======================
# Even though Conditional Branching provide us a great freedom of executing
# words, it's still forward executing. LoopEnd enables to jump back to the
# starting of current word. But currently the problem is there is no way to
# escape the loop yet.

.macro LoopEnd name
    .quad LoopExit
    EntryEnd \name
.endm
