.include "EntryStructure.s"

DictEnd:
    .quad 0x000000000000
    .include "BuiltinEntries.s"
    .include "StringDisplay.s"

DictStart:
