.include "EntryStructure.s"

DictEnd:
    .quad 0x000000000000
    .include "BuiltinEntries.s"
    .include "StringDisplay.s"
    .include "LexerEntries.s"

    Word TestBranch
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
