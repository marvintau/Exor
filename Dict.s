# Dictionary.s
# ================================================
# Dictionary holds all entries. The Macros defined
# in EntryStructure.s enables creating entries and
# forms a linked table, which holds code entries,
# and word entries consisting of other entries.

.include "EntryStructure.s"

DictEnd:
    .quad 0x000000000000
    .include "BuiltinEntries.s"

# ================================================
# LEXER, FIND & EXECUTE
# ================================================
# The foundation of Exor, the basic code and words
# that create a REPL environment to define and run
# words.

    .include "Lexer.s"
    .include "Find.s"
    .include "Execute.s"

    .include "StringDisplay.s"
    .include "Parse.s"
    .include "Define.s"
DictStart:
