
# =========================================================================
# ENTRY STRUCTURE
# =========================================================================
# EntryStructure.s contains a lot of macros. A macro definition contains a
# name, and arguments, and a piece of code. The name that refer to macro
# definition will be replaced by the corresponding code during assembling.
# Consequently, macro definition won't be appearing in the final binary.
# 
# EntryStructure保存了很多宏定义，宏定义包含宏名称，参数以及一小段代码。在代码中引用到
# 宏定义的地方，会把宏定义的内容插入进去，如果有参数，则再以引用宏定义时的参数来替换宏定
# 义内部使用到参数的部分。当然，宏定义本身并不是最终汇编完成代码的一部分。它是我们写汇编
# 代码时很顺手的工具，我们用它来创造很多汇编代码，堆砌数据，并且让程序结构变得清晰。
# 
# 在下面的代码中经常出现的 .quad，.byte, .ascii等，也同样不是最终得到的可执行代码的一
# 部分，它们是被称为“伪指令”的东西。
# 
# 好了好了，如果你现在有点迷糊，那么我们要重新捋一下汇编器的工作方式。和脚本语言刚好相反，
# 汇编器只负责生成汇编代码，并不负责执行它。所以它和汇编器没有什么关系。一个汇编器的工作，
# 就是从一个文件的开头（位置0）开始不断堆砌二进制代码，这些代码有的可以被CPU当作一条指令，
# 有的则是数据。但是汇编器并不管这些。
# 
# 如果你在汇编项目中写了一条，
# 
# add 1051882(%rip),%rax        （意思是把rax寄存器内的东西 和 位于指令指针后1051882
#                                 位置的数据 相加之后再把结果保存在这个位置）
# 
# 对于x86_64架构，它会被翻译成一串机器码
# 
# 48 03 05 ea 0c 10 00 
# 
# 但是，写这么一句话，和你直接把这七个字节的内容堆进汇编器当前指针位置，是一样的，即
# 
# .quad 0x0000100cea050348
# 
# 注意quad中数字的顺序和上面刚好相反，原因是.quad中低位的数字会被先写入，高位的数字会被后
# 写入，最后还要在第8个字节的位置补0。当然最后一个0并不是一个可以用的CPU指令，所以这么写
# 也只能保证这一条指令被执行，后面的就不知道了。因为Intel CPU的指令长度都是不一样的。
# 
# 说了这么多主要是为了揭示汇编器的工作原理，它有一个指针，指向二进制代码中即将要写入的位置，
# 就像录音机（暴露年龄）的磁头一样。它一边扫过汇编代码，就是你现在正在看的东西，一边弄明白
# 你想让它往二进制代码里写什么，如果是一个宏定义，那么就翻回去找到宏定义再插入进来，如果是
# 上面的伪指令，那么就把伪指令代表的数字插进来。
# 
# 另外除了宏，另外一个常见的是语句标号，就是一个从每行开头起，以冒号结尾的一个名称。它相当于
# 编译器所使用的变量，在汇编过程中会把当前的地址（就是当前磁头的位置）赋给它，在以后再次遇到
# 它的场合，则会用它所对应的地址来代替。而这个语句标号的定义也不会占用汇编出的二进制代码的位
# 置。
# 


# STRING MACRO
# ======================
# Char array with length
#
# String是最简单的宏，它包含一段ascii码，和这段ascii码的长度。长度位于字符串内容前面的
# 8个字节（其实一般用不了这么多）。如果运行时获取到了这个字符串，则可以通过这个长度来得到
# 字符串后面的内容。

.macro String name, content
	Length\name:
		.quad (End\name - \name)
	\name:
		.ascii "\content"
	End\name:
.endm

# =========================================================================
# ENTRY HEADER
# =========================================================================
# Contains merely a string indicating the name. The quad after the string
# indicates the distance between the actual entry entering point and the
# header of the entry.
# 
# 然后我们到了“词条”相关的定义，词条相关的定义就是一个header，header只包含一个字符串，
# 以及这个词条将如何被执行，这部分先不用管，到用到它的时候就知道了。所以我们知道header的
# 构成：8个字节代表这个Entry的名字长度，后面是长度为由这8个字节的数字所代表长度的字符串，
# 字符串结束后是1个字节，存储InterpretMode。

.set INTERPRET_ALWAYS, 0x1
.set INTEPRET_NORMAL, 0x0

.macro EntryHeader name, IntepretMode=INTEPRET_NORMAL

    Header\name:
        String Entry\name, "\name"
        .byte \IntepretMode  
    \name:

.endm

# =========================================================================
# ENTRY END
# =========================================================================
# The quad following the label stores the offset from the dictionary end
# (DictEnd) to current entry header. The data contained in this macro is
# actually a part of next entry, used as the link to its previous entry.
# 
# 词条的结尾，只包含一个quad（就是一个8字节长的单位）长。你需要在这里警觉一点，仔细看一下
# Header\name，它出现在上方Header的宏定义里面。在实际代码中Header\name是一个语句标号，
# 在编译时就会替换为一个相对的内存地址。当一个“词条”定义完时，这个地址就被保存在了词条的
# 末尾。
# 
# 为什么要这么做？因为我们在定义一个词条header的时候并不知道它要在哪里结束，但是定义end
# 的时候却已经知道了它在哪里开始。汇编器只会扫一遍汇编代码，如果我们把表示结尾地址的label
# 定义在了header里，汇编器扫到header的时候只会认为你写了一个未经定义的label。
# 
# 由于每个entry都是在内存中紧紧挨着，如果汇编器就是从位置0把每个entry都这样挨个码到一起，
# 那么如果我们知道了一个entry的地址，那么只要从这个地址往回撤8个字节，就可以找到上一个
# entry的起始位置。如此往复，我们就能遍历整个entry了。

.macro EntryEnd name

    EntryEndOf\name:
	.quad Header\name

.endm

# =========================================================================
# ENTRY TRAVERSING ROUTINES
# =========================================================================
# 好的，看了这么多宏，这是我们第一次接触到真实的汇编代码。
# 
# leaq指令叫做“取有效地址” Load Effective Adddres (quad)，一次取八个字节，操作64位寄
# 存器。
# 
# EntryReg在使用场合要填进去实际的寄存器名称，它要专门用来存储Entry的地址。(EntryReg)代
# 表EntryReg这个寄存器 -> 所保存的数字 -> 所代表的地址 -> 上 -> 所保存的数字
# 
# 那么 leaq则代表，把上面这么一坨东西，塞进EntryReg里面去，把原有的东西覆盖掉。

.macro GoToEntry EntryReg
    leaq (\EntryReg), \EntryReg
.endm

.macro GoToNextEntry EntryReg
    movq -8(\EntryReg), \EntryReg
    GoToEntry \EntryReg
.endm

# Let EntryReg stores the address of definition.
# The offset depends on the content between the
# header label and content label.

.macro GoToDefinition EntryReg
    addq (\EntryReg), \EntryReg
    leaq 9(\EntryReg), \EntryReg
.endm



# =========================================================================
# CODE ENTRY & WORD ENTRY
# =========================================================================
# Both code and word entry extends the EntryHeader with one quad, which
# stores the address of the beginning of excutable code. For code entry,
# it will be the starting address of the following code, while for word
# entry, the address of EnterWord.

# Meanwhile, code entry always end up with ExecuteNextWord, which leads
# to the next word. Thus we include this in CodeEnd macro. Word entry is
# always finished up with ExitWord, a subroutine that leads back to 
# 
# 有了这么顺手的工具，截下来我们要定义两种entry，一种entry中包含了可以直接执行的汇编代
# 码，我们将来要在其它的汇编文件中去写这些代码，还有一种没有包含直接执行汇编的代码，
# 但却包含了这些含有汇编代码的entry的地址，然后按定义依次执行汇编代码。当然它包含的既可
# 以是含有汇编代码的entry，也可以是其它间接引用的entry。
# 
# 所以呢，我们只要用汇编写少量常用的操作的entry，剩下的就是去组合这些entry形成新的entry
# 就好啦。
# 
# 至于里面的构造为什么不一样，是我们截下来要讨论的事情。在这里你只需要留心两件事
# 
# 第一， Code是我们所定义的包含汇编的entry，那么有两个问题，如果现在指令指针是位于
# 这个entry的开头的地址，它要怎么跳到实际的指令的地方？毕竟中间是entry名字之类的字
# 符串都不能执行啊。然后，那个ExecuteNextWord又是什么鬼？
# 
# 第二，Word是我们所定义的不包含汇编，却包含其它entry地址的entry，那么它是怎么执行的，
# 那个EnterWord是怎么回事，Exit又是怎么回事？

.macro Code name, IntepretMode=INTEPRET_NORMAL
    EntryHeader \name, \IntepretMode
        .quad ActualCodeOf\name
    ActualCodeOf\name:
.endm

.macro CodeEnd name
    jmp ExecuteNextWord
    EntryEnd \name
.endm

.macro Word name, IntepretMode=INTEPRET_NORMAL
    EntryHeader \name, \IntepretMode
        .quad EnterWord
.endm

.macro WordEnd name
    .quad Exit 
    EntryEnd \name 
.endm


# 好，牢记这几件事，我们先回到Dict.s。