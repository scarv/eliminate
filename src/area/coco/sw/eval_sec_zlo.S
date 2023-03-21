
.macro sec.zlo  imm
.insn u CUSTOM_2, x0, \imm
.endm

.org 0x80
nop
sec.zlo  0xFFE0
sec.zlo  0x0000
sec.zlo  0xFFE0
nop
nop
nop
nop
nop
nop
nop
nop
nop
