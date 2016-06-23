# Initialize LocateWord
# =====================
# r8 always stores the starting of Input buffer, yet
# r9 always stores the length of the buffer.

Code InitLocateWord
    leaq InputBuffer(%rip), %r8
    addq InputBufferLength(%rip), %r9
CodeEnd
