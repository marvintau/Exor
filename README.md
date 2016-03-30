# Exor

## 0. Intro
Exor is an attempt of creating a software system, which exposes all computing resources, and helps user to understand and control their computer system. The basic idea is to use the minimal resources to implement a REPL environment, and build up different components in a bottom-up manner. Thus naturally assembly language is chosen to implement this system.

Notably, by "minimal" it doesn't necessarily mean to be optimal, because it's basically impossible for human being to write highly compacted and coupled assembly code like what generate by compiler, yet keeping it well structured and modularized. And in the very beginning stage, it can only run as an application on an existing OS, which means it can hardly beat an app written in high-level language and well optimized by modern compiler. However, as we all know, that a system has to be less coupled, with less a priori knowledge, in order to gain the ability of long-term evolving.

Exor is not another OS. It's not particularly prepared for human to operate computer better. Exor aims to automate the repetitive work of human being. In another word, The Exor wants to take over the control of computer, and saves human's time spent on operating computers.

## 1. Rationale
I've been using computer for really long time. However if you ask me "how computer works", I can hardly give an answer that satisfying both of us. Modern personal computer is a complex system, It contains unimaginable computing resources. We could type something on our keyboard, and observe that some information jumps out of screen, we still have no idea about what happened inside the computer during this period.

I used to work on embedded system for a while. What amazed me is that there are some OS like Contiki and TinyOS which can run inside a chip with only 2KB of RAM. So how did we stuffed a laptop or a desktop computer with 8GB memory and even more storage space, and how did we slowed down a CPU which can execute millions of instructions per second?

After I read an essay, "Building a robust system", written by Gerald J Sussman, I realized that our computer system is well taylored, highly coupled, and prone to make error. We have been trying hard to avoid error, but never setup the mechanism for computer to deal with error.

Thus I decided to design a system, with less a priori knowledge, and takes computing resource as little as possible. It might look stupid at first, but it can grow.

## 1. Ascendant
The system is largely inspired by Forth, a stack-based low-level system. Forth
organizes the code in dictionary form (word - definition), of which the definition could be either assembly code or other words. Words are successively interpretted, but you could also define a word that determines the behaviour of interpreting following words. It's pretty much like a low-level Lisp, and could be even simpler than Lisp because it doesn't even contains parentheses, and use whitespace as the  only delimiter.

The most valuable part of Forth for me, is that it provides a minimum REPL environment which uses least hardware resource, (CPU usage, memory, etc.) leaving the remaining part for user. And the design principle of Forth is the best candidate for building such a system.


## 3. Recent Goal and Current Progress
Writing assembly could be slow, since there is no stuff like garbage collection. You have to deal with register and memory, data and address. You need to be highly alerted when writing assembly. I'm currently writing a set of macros to generate code, which saves a lot of repetitive work, and avoids mistake. This makes the starting phase even slower. The length of the assembly code that similar to a class in a high-level OO language can only do what a function does in such language.

There are a couple of components of the current design.

1. __Lexer__
   lexer splits the keyboard input into words by whitespace, and then tells entry matcher to find corresponding entry for each word.
2. __Entry Manager__
   as aformentioned, all the data and code is organized as entry, or a key-value pair. Entry manager contains a set of macro, that defines entries in compiling time and operates entry (currently only find).
3. __Eval Stack__
   the idea borrowed from "return stack" of Forth. the entries to be evaluated are pushed into a stack, and then get evaluated from the top of stack.
4. __Locating facilities__
   If the entry contains executable code, then the code must know where's the next entry to be executed after itself is done. That's an interesting feature that different from modern system, that the system kernel doesn't take care of the running status of the code. Locating facilities stores and restores the addresses that indicating entries and stack.

Currently the first three are done.