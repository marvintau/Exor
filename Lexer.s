# =========================================================================
# LEXER
# =========================================================================
# 接下来我们就可以随意书写Code和Word两种不同的词条了。那么接下来我们要写什么呢？我们
# 要做两件事，第一是允许用户从键盘输入内容，第二是让Concordia有一个最小的运行时环境，
# 或者说一个REPL环境，可以即时地解释用户输入的代码。
# 
# 这是为什么我们的每个词条都需要有一个字符串的名字。在我们现在看到的代码中，可以直接用
# 语句标号来构建一个Word和Code词条，但是在运行时环境里，这些位置对于用户都是不可见的，
# 在用户第一次执行他从键盘上输入的代码时，是一定要通过字符串匹配来找到这些词条的。
# 
# 在这个文件里我们做第一件事，就是能够读取用户从键盘上输入的内容，并且进行简单的分词。



# =========================================================================
# InitLocateWord
# =========================================================================
# BufferAddressRegister和InputBufferLength都是我们之前在DataSegment里面见过的，
# 在这里我们用%r8来初始化它们。我们在扫字的时候，是从用户输入的buffer的最后一个字母开
# 始扫起。这是为什么我们要让%r8指向buffer末尾的原因。

Code InitLocateWord
    movq BufferAddressRegister(%rip), %r8
    addq InputBufferLength(%rip), %r8
    movq %r8, WordStartOffset(%rip)
CodeEnd InitLocateWord

# =========================================================================
# ScanInputBuffer
# =========================================================================
# 在这里我们做了一次系统调用，让用户通过键盘输入一段文字，然后再保存到指定的buffer地址

Code ScanInputBuffer
    movq    $SyscallRead, %rax
    movq    $(0), %rdi
    movq    BufferAddressRegister(%rip), %rsi
    movq    $(InputBufferEnd - InputBuffer), %rdx
    syscall

    decq    %rax
    movw    $(0x2020), (%rsi, %rax)

    movq    %rax, InputBufferLength(%rip)
CodeEnd ScanInputBuffer

# LOCATE WORD BOUND
# =====================================================
# A register holds the address of last char decrease every
# time and checks two consecutive chars (a bigram) at that
# position. If a bigram wit "C_" pattern is found, then
# assign the address to EndReg, and if a bigram with "_C"
# found, then leave the subroutine, and the current char
# position (StartReg) along with the end position (EndReg)
# will be used in the next stage.

Code LocateWordBound
    
    xorq %rdx, %rdx

    leaq InputBuffer(%rip), %rax 

    NextBigram:
        cmpq %r8, %rax 
        je   WordLocated

        # First to handle the quoted string, if is a quote
        # then check if it's an open or closed quote. If
        # it's not a quote but currently within an opening
        # quote, Just move to next bigram.
        cmpb $(0x22), (%r8)
        je   Quoted
        cmpq $(0x1), %rdx
        je   MoveCurr

        # If it's not the issue of quoted string, separate
        # the words with space.
        cmpb $' ', (%r8)
        je   StartWithSpace
        jne  StartWithChar

        Quoted:
            cmpq $(0x5c), -1(%r8) # escaped
            je MoveCurr

            cmpq $(0x1), %rdx
            jne OpenQuote
            je  CloseQuote

            OpenQuote:
                movq $(0x1), %rdx
                movq %r8, %r9
                incq %r9
                jmp MoveCurr

            CloseQuote:
                xorq %rdx, %rdx
                jmp WordLocated

        StartWithSpace:
            cmpb $' ', -1(%r8)
            je  MoveCurr 

            CharNext:
                movq %r8, %r9
                jmp MoveCurr 

        StartWithChar:
            cmpb $(0x20), -1(%r8) 
            jne MoveCurr 

            SpaceNext:

                jmp WordLocated

        MoveCurr:

            decq %r8
        
        jmp NextBigram 

    WordLocated:
        subq %r8, %r9

CodeEnd LocateWordBound

Code LoopWhileufferEndNotReached
    leaq InputBuffer(%rip), %r9 
    cmpq %r8, %r9
    je Reached
        decq %r8
        ReEnterWord
    Reached:    

CodeEnd LoopWhileufferEndNotReached 

Word ExecuteSession
    # %r8 as Buffer Start Register, which holds the starting position
    # where lexer starts (which actually is the end of buffer). While
    # %r9 the Buffer End register, which sometimes holds the position
    # where the word starts, sometimes holds the length of the word
    
    .quad LocateWordBound
    .quad ParseWord
    .quad LoopWhileufferEndNotReached 

WordEnd ExecuteSession

Word InitScan
    .quad InitLocateWord
    .quad ScanInputBuffer
    .quad ExecuteSession
WordEnd InitScan
