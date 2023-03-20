
.macro sec.xori rd, rs1, imm 
.insn i CUSTOM_0, 5, \rd, \rs1, \imm
.endm

.org 0x80
nop
sec.xori x5,  x5, -1
and      x6,  x6, x6
sec.xori x12, x5, -1  # overwrite a share with another share to check if there's now an architecutral leakage
nop
nop
nop
nop
nop
nop
nop
nop
nop
