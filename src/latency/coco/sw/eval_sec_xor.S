# this micro-benchmark should work with the label file `eliminate-label.txt`

.macro sec.xor  rd, rs1, rs2 
 xor \rd, \rs1, \rs2
.endm

.org 0x80
nop
nop
sec.xor  x5,  x5, x7
and      x6,  x6, x6
sec.xor  x12, x5, x7  # overwrite a share with another share to check if there's now an architecutral leakage
nop
nop
nop
nop
nop
nop
nop
nop
nop
