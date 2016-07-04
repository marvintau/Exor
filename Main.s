/**
 *  Exor experiment program
 *  =======================
 *  Containing learning notes and resources
 */

# TEXT segment
# ==================================================================
# TEXT segment will be assembled as a read-only part of a binary
# executable. Notably not all bytes loaded into memory are permitted
# to be read as instructions. Without being specified, the bytes in
# DATA segment are not permitted to be executed.

.text
.include "IO.s"
.include "Stack.s"
.include "Execute.s"

.include "Dictionary.s"

.globl _main

_main:
    InitDataStack
    InitStack

#MainLoop:

# Now we are going into the part which is hardest to understand in
# this set of code. Prepare yourself with a cup of coffee, and stay
# focus!

# Both InitScan and ExecuteSystemWord are defined somewhere in
# Dictionary.s. You may want to look up there. And it's always
# good to open a terminal, and locate the file containing the word
# with grep <YourWord> -r *

# Now I suppose you have entered Dictionary.s

    # Enter the main routine
    leaq InitScan(%rip), %r11 
    jmp ExecuteSystemWord
    
    SystemExitLabel:
    movq $SyscallExit, %rax
    syscall

.data
.include "DataSegment.s"

.bss
Memory:
