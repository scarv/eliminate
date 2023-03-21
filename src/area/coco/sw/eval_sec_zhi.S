
.macro sec.zhi  imm 
.insn u CUSTOM_3, x0, \imm
.endm

.org 0x80
nop
sec.zhi  0xFFFF
sec.zhi  0x0000
sec.zhi  0xFFFF
nop
nop
nop
nop
nop
nop
nop
nop
nop
