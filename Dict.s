# Dictionary.s
# ================================================
# Dictionary holds all entries. The Macros defined
# in EntryStructure.s enables creating entries and
# forms a linked table, which holds code entries,
# and word entries consisting of other entries.

.include "EntryStructure.s"

DictEnd:
    .quad 0x000000000000

# ================================================
# LEXER, FIND & EXECUTE
# ================================================
# The foundation of Exor, the basic code and words
# that create a REPL environment to define and run
# words.

# The words in the three modules are highly coupled,
# Thus the registers are not passed through stack,
# described as below:

# r8 & r9: Word starting address in input buffer,
#          and word length
# r10:     Return stack pointer, initialized and
#          operated by macros defined in Stack.s
# r11:     Entry pointer, operated by traversing
#          routines defined in Find.s
# r12:     Entry pointer for indirect addressing,
#          always points to an address that holds
#          an address that locates executable code.
# r13:     Pointer to the address that holds the
#          NEXT address that to be copied to r12
# r14:     The counter that used for recording 
#          how many words have been compiled.

    .include "Execute.s"
    .include "BuiltinEntries.s"
    .include "Lexer.s"
    .include "Find.s"
    .include "Define.s"

    .include "StringDisplay.s"
DictStart:
