# this micro-benchmark should work with the label file `eliminate-label.txt`

.macro sec.ori  rd, rs1, imm 
.insn i CUSTOM_0, 3, \rd, \rs1, \imm
.endm

.org 0x80
nop
sec.ori  x5,  x5, 0
and      x6,  x6, x6
sec.ori  x12, x5, 0   # overwrite a share with another share to check if there's now an architecutral leakage
nop
nop
nop
nop
nop
nop
nop
nop
nop
