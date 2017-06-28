
# Concordia
# ==============================================================================
# 一段奇妙的汇编代码
# 
# Concordia是一个类似forth的实现，在实现上很大程度上是参考了JonesForth。Forth的语法结构和
# 实现都相当贴近CPU提供的指令，因此用高级语言实现的Forth并不是很能体现出它的优势，相反汇编语
# 言却更加容易。JonesForth提供了这个思路和教程。
# 
# 目前能找到的JonesForth是一位叫Cheng-Chang Wu的朋友fork的，里面的两段代码jonesforth.s
# 和jonesforth.f是原始的JonesForth代码。
# 
# https://github.com/chengchangwu/jonesforth
# 
# Forth是一个非常古老的计算机语言，受到当时计算机的限制，Forth的代码也都比较晦涩，接下来我所
# 希望实现的Concordia与之刚好相反，在编码风格上希望采用尽可能详细的名称和符号，让代码本身像
# 自然语言一样具有可读性。因此符号名都会比较长，看起来会有些啰嗦。

.set SyscallExit,		0x2000001
.set SyscallDisplay,    0x2000004
.set SyscallRead,		0x2000003



.equiv STR_LENG_FIELD_LEN, 8

# Enabling Self-modifying/Self-mutating Code
# =============================================================================
# self-modifying或self-mutating叫法不一，主要是指代码在运行过程中可以更新自己的另一部分。
# 这样做当然是不安全的，并且在大部分情况下是被操作系统禁用的。对于Havard架构的处理器，即缓
# 存区分为指令缓存和数据缓存的，这样做会无法使用数据缓存，并使得指令缓存失效，因此也是低效的。
# 
# 以下部分代码调用了BSD SYSCALL的mprotect，Linux这一syscall并不一样，此处先解决在OSX下
# 的问题
# 
# Ref:
# https://stackoverflow.com/questions/16679478/what-does-the-usage-of-mprotect-as-an-asm-syscall-look-like-with-respect-to-it

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

# TEXT 代码段，代码从这里正式开始
# =============================================================================

.text

.globl _main

_main:

    # 先调用mprotect的宏定义, mprotect的第一个参数是起始地址，label(%rip)的寻址方式是
    # IA-64特有的，未来这段代码移植到8086或ARM上是都要改。那么ExecutableSegment(%rip)
    # 就定位到了内存地址中的data段。
    mprotect ExecutableSegment(%rip), $PAGE_SIZE, $PROT_ALL 

    # Where the new world begins
    jmp ExecuteSystemWord
    
    SystemExitLabel:
    movq $SyscallExit, %rax
    syscall


# DATA 数据段，托mprotect的福，以下部分也能像代码一样执行了
# =============================================================================
.data
ExecutableSegment:

# DataSegment中定义了一些常量，包括从键盘读取的buffer内容，指针等等
.include "DataSegment.s"

# Dict是Concordia奥妙所在，打开这个文件一探究竟吧
.include "Dict.s"

