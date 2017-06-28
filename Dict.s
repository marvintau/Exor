# ==============================================================================
# Dictionary.s
# ============================================================================== 
# Dictionary保存了所有的“词条”，词条是Concordia可执行代码的主要组成部分，Dictionary是一个
# 基础的链表结构，顺序地存储了这些词条。下面的EntryStructure保存了很多宏定义，通过它就可以创
# 建出可执行的词条了。打开看看吧。

.include "EntryStructure.s"

# 结束了EntryStructure之后，我们来看这个Dictionary到底是如何构成的。首先你可能会问，为什么
# DictEnd的标号是在上面，而DictStart是在最末尾。原因在EntryStructure里面已经解释过，因为
# 遍历本身就是通过从每个entry的开头倒回去，找到上一个entry的开头来实现的。

DictEnd:
    .quad 0x000000000000

# 以下几个文件就是Concordia的基石。那么我们就挨个看一下这几个引用的文件里都有什么吧。

    .include "Execute.s"
    .include "BuiltinEntries.s"
    .include "Lexer.s"
    .include "Interpret.s"
    # .include "Define.s"

    .include "StringDisplay.s"
DictStart:
