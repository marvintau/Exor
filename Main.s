/**
 *  Exor experiment program
 *  =======================
 *  Containing learning notes and resources
 */

.equiv STR_LENG_FIELD_LEN, 8

# For enabling self-modifiable code 
# =================================
.equiv BSD_MASK,    0x2000000
.equiv SYS_MPROTECT, 74 | BSD_MASK        /* MPROTECT syscall */
 
# These constants for mprotect(2) are from <sys/mman.h>
.equiv PROT_READ,  0x01         /* pages can be read */
.equiv PROT_WRITE, 0x02         /* pages can be written */
.equiv PROT_EXEC,  0x04         /* pages can be executed */
 
.equiv PROT_ALL, PROT_READ | PROT_WRITE | PROT_EXEC
.equiv PAGE_SIZE, 8192 

.macro mprotect addr, len, prot
        leaq \addr, %rdi
        movq \len,  %rsi
        movq \prot, %rdx
 
        movq $SYS_MPROTECT, %rax
        syscall
.endm

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

.globl _main

_main:

    mprotect ExecutableSegment(%rip), $PAGE_SIZE, $PROT_ALL 
CheckReturn:
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
ExecutableSegment:
.include "DataSegment.s"
.include "Dict.s"

