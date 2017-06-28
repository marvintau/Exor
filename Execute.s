# For stack operations, only two registers are used in each
# macro functions. %r10 stores the stack address, while %r14
# are for storing the popped data, which is only appear in
# pop-related macro functions.

# 这里定义了三个宏，分别是初始化栈，压栈和出栈。除非整个上下文都被保存，
# 否则默认情况下r10寄存器一直都是栈指针。

.macro InitStack
    leaq Stack(%rip), %r10
.endm

.macro PushStack Reg
    movq \Reg, (%r10)
    leaq  8(%r10), %r10
.endm

.macro PopStack Reg
    leaq -8(%r10), %r10
    movq (%r10), \Reg
.endm


# =========================================================================
# SystemEntrance
# =========================================================================
# 我们并没有用整个Entry，而是只用了ExecuteSystemWord之后的部分，如果你回到Main.s就
# 可以看到。那么这里面做了几件事，第一就是上面提到的初始化栈，但是后面的就不是非常清楚了。
# 没有关系，现在我们进入到了理解Concordia最难，也是最关键的部分。
# 
# 不要着急，你可以先去伸个懒腰，泡杯咖啡。回来之后先不要纠结这里，我们要到下面，先看一下
# ExecuteNextWord和EnterWord都干了什么，以及我们在EntryStructure里遗留的问题是怎么
# 解决的。

EntryHeader SystemEntrance
ExitAddress:
    .quad SystemExit

ExecuteSystemWord:
    InitStack

    leaq ExitAddress(%rip), %r13

    leaq InitScan(%rip), %r11 
    movq %r11, %r12
    jmp  *(%r12)
EntryEnd SystemEntrance


# =========================================================================
# ExecuteNextWord
# =========================================================================
# 好，请回想一下上次遇见ExecuteNextWord的时候，是我们运行到了代码的末尾，一个jmp跳转
# 指令跳转到了这里。注意下面这个Entry既不是Code也不是Word，回去看EntryHeader的定义，
# ExecuteNextWord正是汇编代码开始的位置。
# 
# 那么在这里都发生了什么事呢？
# 
# 举个例子，假如我们已经在一个Word里面，比如说这个：
# 
#         +===============================+             
#         |  Word InterpretIteration      |
#         +-------------------------------+ 
#         | .quad MatchName               | 
#   ----> | .quad Eval                    |
#         | .quad NextEntry               | 
#         | .quad LoopWhileEndNotReached  | 
#         | .quad DefineLiteral           | 
#         +-------------------------------+
#         |  WordEnd InterpretIteration   | 
#         +===============================+                          
# 
# 我们到了Eval这一步，要进行到下面的NextEntry，要怎么办呢？
# 
# 答案是下面代码汇编部分的第二行，
# 
# leaq 8(%r13), %r13
# 
# %r13保存了一个地址，8(%r13)原本代表%r13所保存的地址往后数8个字节的位置，上面保存的值。
# 但是leaq没有去找这个值，而是仅仅计算出这个地址，然后又赋给了%r13。这么做和另一件事
# 
# addq $8, %r13
# 
# 效果是一样的，但是少了很多副作用，对于地址的计算还是多用lea指令。
# 
# 好了，那么我们知道了，原来%r13是专门用来遍历一个Word里面的地址序列的。那么前后两条指令
# 又是干什么的呢？
# 
# movq (%r13), %r12
# 
# 这行代码，是把%r13里面保存的数字所代表的地址上保存的值，传给了%r12，那么现在%r12指向的
# 是哪里呢？我们看一下前两行代码执行后的结果：
#                                                
#                                            +--> Code Eval        
#         +===============================+  |        cmpq $(0x0), %r14              
#         |  Word InterpretIteration      |  |        je Evaluate 
#         +-------------------------------+  |        Compile  
#         | .quad MatchName               |  |    Evaluate:  
#    r13  | .quad Eval -------------------+--+        EvaluateCore %r11  
#   ----> | .quad NextEntry               |       AllDone:  
#         | .quad LoopWhileEndNotReached  |           movq $(3), %rax  
#         | .quad DefineLiteral           |           BranchStep %rax  
#         +-------------------------------+       CodeEnd Eval 
#         |  WordEnd InterpretIteration   |           
#         +===============================+                                    
# 
# 当我们把Code宏展开后，看到的会是这样：
#                                            +--> Eval:
#                                            |        .quad ActualCodeOfEval
#                                            |    ActualCodeOfEval:
#         +===============================+  |        cmpq $(0x0), %r14              
#         |  Word InterpretIteration      |  |        je Evaluate 
#         +-------------------------------+  |        Compile  
#         | .quad MatchName               |  |    Evaluate:  
#    r13  | .quad Eval -------------------+--+           EvaluateCore %r11  
#   ----> | .quad NextEntry               |       AllDone:  
#         | .quad LoopWhileEndNotReached  |           movq $(3), %rax  
#         | .quad DefineLiteral           |           BranchStep %rax  
#         +-------------------------------+       CodeEnd Eval 
#         |  WordEnd InterpretIteration   |           
#         +===============================+                                    
# 
# 最后的
# 
# jmpq *(%12)
# 
#       
# 是让指令指针跳向
# 
#           %r12          (%r12)                              *(%r12)
# Eval的地址(Eval)所对应的值(.quad ActualCodeOfEval)，所对应的地址(ActualCodeOfEval)
# 
# 这是一个二段跳式的寻址，也是为什么Code的定义要多一个ActualCodeOf的累赘的东西的原因。唔
# 等一等，如果它累赘的话，为什么不能直接让Eval后面就跟上汇编代码，却还要多添加8个字节并且
# 多一次跳跃的寻址呢？
# 
# 你可能已经猜到了，下一个Entry可能不一定是Code，也会是Word，那么Word是怎么处理的呢？
# 我们往下看。


EntryHeader ExecuteNextWord
    movq  (%r13), %r12
    leaq 8(%r13), %r13
    jmpq *(%r12)
EntryEnd ExecuteNextWord

# =========================================================================
# EnterWord
# =========================================================================
# 
# +=========================+
# | Word ParseWord          |
# +-------------------------+
# |     .quad EnterEntry    |  r12
# |     .quad InterpretIte..| ---->  InterpretIteation:
# | WordEnd ParseWord       |            .quad EnterWord
# +=========================+            .quad MatchName
#                                        ...
# 
# 一个Word里面是没有ActualCodeOf...的，它对应的位置正是EnterWord的地址，因此对于Word，
# 
# jmpq *(%12)
#
# 是让指令指针跳向
#            %r12                (%r12)                     *(%r12)
# Inter的地址(Interp...)所对应的值(.quad EnterWord)，对应的地址(EnterWord)
# 
# 所以没有错，两种情况指令指针都跳向了可以执行的代码，那么EnterWord究竟干了什么呢？
# 
# 首先，%r13被压栈了，或者说就是暂时被存档了。然后%r12向下挪了8个字节，指向了word的第一个引用地址
# 
# +=========================+
# | Word ParseWord          |
# +-------------------------+
# |     .quad EnterEntry    |  
# |     .quad InterpretIte..| ----+  InterpretIteation:
# | WordEnd ParseWord       |     | r12  .quad EnterWord
# +=========================+     +----> .quad MatchName
#                                        ...
# 
# 然后...
# 
# +=========================+
# | Word ParseWord          |
# +-------------------------+
# |     .quad EnterEntry    |  
# |     .quad InterpretIte..| ----+  InterpretIteation:
# | WordEnd ParseWord       |     | r12  .quad EnterWord
# +=========================+     +----> .quad MatchName
#                                   r13  ...
# 
# r13保存了当前r12的地址！
# 
# 最后，执行了ExecuteNextWord！在本例中，r12就继续去寻找MatchName所指向的代码了！当运行至
# ExecuteNextWord的时候，我们可以参考上面关于ExecuteNextWord的描述知道r12和r13的行为。

EntryHeader EnterWord
    PushStack %r13
    leaq 8(%r12),  %r12
    movq   %r12,   %r13
    jmp ExecuteNextWord
EntryEnd EnterWord

# 明白了ExecuteNextWord和EnterWord，我们就知道了Concordia代码的重要组成部分，同时请牢记，
# 现在%r12和%r13已经都被指派了特别的用途。

