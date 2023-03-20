# this micor-benchmark should work with the label file `class-1.txt`

.macro sec.srli rd, rs1, imm 
.insn i CUSTOM_0, 7, \rd, \rs1, \imm
.endm

.org 0x80
nop
slli     x5,  x5, 4
and      x6,  x6, x6
sec.srli x12, x5, 4   # overwrite a share with another share to check if there's now an architecutral leakage
nop
nop
nop
nop
nop
nop
nop
nop
nop
