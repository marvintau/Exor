.include "EntryStructure.s"

DictEnd:
    .quad 0x000000000000
    .include "BuiltinEntries.s"
    .include "StringDisplay.s"

    Word TestBranch
        .quad Branch
        .quad Jesus 
        .quad Exit
        .quad Maria
    WordEnd TestBranch

    Code Move
        movq $(0xdead), %r11
    CodeEnd Move

    Code Mov2
        movq $(0xbeef), %r11
    CodeEnd Mov2

DictStart:
