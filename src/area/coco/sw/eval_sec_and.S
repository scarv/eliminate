# this micro-benchmark should work with the label file `eliminate-label.txt`

.macro sec.and  rd, rs1, rs2 
.insn r CUSTOM_0, 0, 0, \rd, \rs1, \rs2
.endm

.org 0x80
nop
not      x13, x0
sec.and  x5,  x5, x13 
and      x6,  x6, x6
sec.and  x12, x5, x13  # overwrite a share with another share to check if there's now an architecutral leakage
nop
nop
nop
nop
nop
nop
nop
nop
nop
