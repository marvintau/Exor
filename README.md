# Exor

## 0. Intro
Exor is an attempt of creating a computer system from the scratch. I avoid using
the term "operating system" because the design is very different. First the system
is written in assembly. Currently (and in recent future), the system is based on
x86_64, then (maybe after 1 yr) will be migrated to ARM Cortex A-series (on my
little Raspberry pi), and finally (maybe years later) it will take over all my
computers (or all hackable Turing-complete computing devices).


## 1. Ascendant
The system is largely inspired by Forth, a stack-based low-level system. Forth
organizes the code in dictionary form (word - definition), of which the definition
could be either assembly code or other words. Words are successively interpretted,
but you could also define a word that determines the behaviour of interpreting
following words. It's pretty much like a low-level Lisp, and could be even simpler
than Lisp because it doesn't even contains parentheses, and use whitespace as the 
only delimiter.

The most valuable part of Forth for me, is that it provides a minimum REPL environment
which uses least hardware resource, (CPU usage, memory, etc.) leaving the remaining
part for user. 

## 2. Okay but why bother ... ?
I used to be an engineer working on embedded systems, such as sensor network and SoC.
There are a lot of nifty OS such as TinyOS and Contiki, which provides full-fledged
functionalities of an OS, but take really small memory footprint. The memory of a sensor
is typically 2k. So I'm always wondering how does the memory consumed on our laptop with
8GB memory.

I also learned and used a lot of programming languages during my previous projects, which
contains very complex concepts. A lot of patterns are invented to increase the productivity
of the software industry, by sacrificing the productivity of individuals. However, there
is an ancient concept of programming, which is in the heart of COMPUTING (not programming),
is macro. The foundation of computing is rewriting, which is exactly what macro doing. And
Forth is just built based on this concept.

The last but not least, I don't understand how does GCC work. I want to try to write code
with assembly. Throughout my previous projects, a lot of crucial code are written in
assembly. A computer based signal processing framework, GNU Radio, contains a component
called VOIK kernel, which is fully written in assembly, with SIMD instructions. I'm also
wondering if we could program ray-tracing engine with the GPU ABI interfaces. However, most
of the assembly code have poor readability, due to bad naming and format conventions. I'm
wondering if it will be better by introducing modern naming and formatting conventions.

## 3. Recent Goal and Current Progress
Writing assembly could be slow, since there is no stuff like garbage collection. You have to
deal with register and memory, data and address. You need to be highly alerted when writing
assembly. I'm currently writing a set of macros to generate code, which saves a lot of
repetitive work, and avoids mistake. This makes the starting phase even slower.

The functioning part of the code contains two parts. The first one is a simple lexer (since
forth doesn't need a parser), which reads from keyboard buffer and finds the offset of
delimiters for each word. The second is an interpreter. For each word, it finds the preset
definitions from a data region called "dictionary". The entries in dictionary are currently
hardcoded, but will be implemented as a command in future.

After getting this done, two main functions which is currently hardcoded will be implemented as
command read from keyboard buffer. The first is "find", which finds the definition of a particular
word. THe second is "define", which add new entries to the dictionary region.

Currently the dictionary region is very simple, just a set of strings. A quad-long number indicating
the string length is placed ahead of string. I hope I can implement something like CRUD operations
over a database, thus I need to design a more elaborated data structure for dictionary in future.
