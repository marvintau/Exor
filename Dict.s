
# Dictionary.s
# ===============================================
# Dictionary is a special section in the executable, and
# basically it is a portion that organizes all executable
# code in Exor. Dictionary contains entries, which is similar
# to what we call it a function, or subroutine, or procedure.
# It's a piece of code, which will be executed as sequential
# instructions, with some additional information.

# You may first open the files such as BuiltinEntries.s or
# StringDisplay.s to see what an entry looks like, and then
# come back to EntryStructure.s, to check out what forms an
# entry.

.include "EntryStructure.s"

DictEnd:
    .quad 0x000000000000
    .include "BuiltinEntries.s"
    .include "StringDisplay.s"
    .include "LexerEntries.s"
    .include "Find.s"
    .include "Eval.s"
DictStart:
