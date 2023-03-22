// micro-benchmarks for custom secure instructions

// class-1
// extern void sec_and_test_asm(uint32_t *r, uint32_t *a, uint32_t *b);
// extern void sec_andi_test_asm(uint32_t *r, uint32_t *a);
// extern void sec_or_test_asm(uint32_t *r, uint32_t *a, uint32_t *b);
// extern void sec_ori_test_asm(uint32_t *r, uint32_t *a);
// extern void sec_xor_test_asm(uint32_t *r, uint32_t *a, uint32_t *b);
// extern void sec_xori_test_asm(uint32_t *r, uint32_t *a);
// extern void sec_slli_test_asm(uint32_t *r, uint32_t *a);
// extern void sec_srli_test_asm(uint32_t *r, uint32_t *a);

// class-2 
// extern void lsmseed_rw_test_asm(uint32_t *r);
// extern void sec_lw_test_asm(uint32_t *r);
// extern void sec_sw_test_asm(uint32_t *r);

// class-3
// extern void sec_zlo_test_asm(uint32_t *r);
// extern void sec_zhi_test_asm(uint32_t *r);

// instruction latency measurement
// extern void sec_insn_latency_measurement_asm(uint32_t *r);


// becasue there is a bug in ibex-demo-system re. `rdcycle` instruction; 
// we therefore use `csrr` to read the `mcycle` CSR directly;  
// the address of Machine Cycle Counter (mcycle) CSR is "0xB00"
.macro read_cycle rd 
 csrr \rd, 0xB00 
.endm 


// macros for defination of custom instructions

// class-1

.macro sec.and  rd, rs1, rs2 
 and  \rd, \rs1, \rs2
.endm

.macro sec.andi rd, rs1, rs2 
 andi \rd, \rs1, \rs2
.endm

.macro sec.or   rd, rs1, rs2 
 or   \rd, \rs1, \rs2 
.endm

.macro sec.ori  rd, rs1, rs2 
 ori  \rd, \rs1, \rs2 
.endm

.macro sec.xor  rd, rs1, rs2 
 xor  \rd, \rs1, \rs2 
.endm

.macro sec.xori rd, rs1, rs2 
 xori \rd, \rs1, \rs2 
.endm

.macro sec.slli rd, rs1, imm 
 slli \rd, \rs1, \imm
.endm

.macro sec.srli rd, rs1, imm 
 srli \rd, \rs1, \imm
.endm

// class-2

// Load-Store-Mask SEED (lsmseed) CSR addresses
#define lsmseed0 0x800
#define lsmseed1 0x801
#define lsmseed2 0x802
#define lsmseed3 0x803

// get a Lower-Bit (LB) of the two MSBs
#define LB(x) (x & 1) 
// get a Higher-Bit (HB) of the two MSBs
#define HB(x) ((x>>1) & 1) 

.macro sec.lw  rd, rs1, imm, md 
.insn i CUSTOM_1, 0, \rd,  \imm+1024*LB(\md)-2048*HB(\md)(\rs1)
.endm

.macro sec.sw  rs2, rs1, imm, md
.insn s CUSTOM_1, 1, \rs2, \imm+1024*LB(\md)-2048*HB(\md)(\rs1)
.endm 

// class-3 

.macro sec.zlo  imm
.insn u CUSTOM_2, x0, \imm
.endm

.macro sec.zhi  imm 
.insn u CUSTOM_3, x0, \imm
.endm


// micro-benchmarks

// class-1

.section .text 

.global sec_and_test_asm 

sec_and_test_asm:
  lw       t5, 0(a1)
  lw       t6, 0(a2)
  sec.and  t0, t5, t6
  sw       t0, 0(a0)
  ret 

.global sec_andi_test_asm 

sec_andi_test_asm:
  lw       t5, 0(a1)
  sec.andi t0, t5, 0x0FF
  sw       t0, 0(a0)
  ret 

.global sec_or_test_asm 

sec_or_test_asm:
  lw       t5, 0(a1)
  lw       t6, 0(a2)
  sec.or   t0, t5, t6
  sw       t0, 0(a0)
  ret 

.global sec_ori_test_asm 

sec_ori_test_asm:
  lw       t5, 0(a1)
  sec.ori  t0, t5, 0x0FF
  sw       t0, 0(a0)
  ret 

.global sec_xor_test_asm 

sec_xor_test_asm:
  lw       t5, 0(a1)
  lw       t6, 0(a2)
  sec.xor  t0, t5, t6
  sw       t0, 0(a0)
  ret 

.global sec_xori_test_asm 

sec_xori_test_asm:
  lw       t5, 0(a1)
  sec.xori t0, t5, -1
  sw       t0, 0(a0)
  ret

.global sec_slli_test_asm 

sec_slli_test_asm:
  lw       t5, 0(a1)
  sec.slli t0, t5, 4
  sw       t0, 0(a0)
  ret 

.global sec_srli_test_asm 

sec_srli_test_asm:
  lw       t5, 0(a1)
  sec.srli t0, t5, 4
  sw       t0, 0(a0)
  ret 

// class-2

.global lsmseed_rw_test_asm

lsmseed_rw_test_asm:
  li       t0, 0x1
  csrrw    x0, lsmseed0, t0
  csrr     t1, lsmseed0
  sw       t1,  0(a0)
  li       t0, 0x22
  csrrw    x0, lsmseed1, t0
  csrr     t1, lsmseed1
  sw       t1,  4(a0)
  li       t0, 0x333
  csrrw    x0, lsmseed2, t0
  csrr     t1, lsmseed2
  sw       t1,  8(a0)
  li       t0, 0x4444
  csrrw    x0, lsmseed3, t0
  csrr     t1, lsmseed3
  sw       t1, 12(a0)
  ret

.global sec_sw_test_asm
sec_sw_test_asm:
  li       t0, 0x11
  csrrw    x0, lsmseed0, t0
  li       t0, 0x2222
  csrrw    x0, lsmseed1, t0
  li       t0, 0x11
  csrrw    x0, lsmseed2, t0
  li       t0, 0x44444444
  csrrw    x0, lsmseed3, t0  
  li       t1, 0x01234567
  li       t2, 0x89ABCDEF
  sec.sw   t1, a0,  0, 0
  sec.sw   t2, a0,  4, 1
  sec.sw   t1, a0,  8, 2
  sec.sw   t2, a0, 12, 3
  ret

.global sec_lw_test_asm 
sec_lw_test_asm:
  li       t0, 0x11
  csrrw    x0, lsmseed0, t0
  li       t0, 0x2222
  csrrw    x0, lsmseed1, t0
  li       t0, 0x11
  csrrw    x0, lsmseed2, t0
  li       t0, 0x44444444
  csrrw    x0, lsmseed3, t0  
  sec.lw   t1, a0, 0, 0
  sw       t1, 0(a0)
  sec.lw   t1, a0, 4, 1
  sw       t1, 4(a0)
  sec.lw   t1, a0, 8, 2
  sw       t1, 8(a0)
  sec.lw   t1, a0,12, 3
  sw       t1, 12(a0)
  ret

// class-3

.global sec_zlo_test_asm

sec_zlo_test_asm:
  // move the address of result array from a0(x10) to t3
  mv       t3, a0 
  // s0 (x8) s1 (x9) are callee-saved     
  addi     sp, sp, -8
  sw       s0,   0(sp)  
  sw       s1,   4(sp)  
  // initialize x5-x15 to be non-0
  li       x5,   5
  li       x6,   6
  li       x7,   7
  li       x8,   8
  li       x9,   9
  li       x10, 10
  li       x11, 11
  li       x12, 12
  li       x13, 13
  li       x14, 14
  li       x15, 15
  // erase x5-x15 (0xFFE0 = 0b 1111 1111 1110 0000)
  sec.zlo  0xFFE0     
  // store the values of x5-x15 for printing  
  sw       x5,   0(t3)   
  sw       x6,   4(t3)   
  sw       x7,   8(t3)   
  sw       x8,  12(t3)
  sw       x9,  16(t3)
  sw       x10, 20(t3)
  sw       x11, 24(t3)
  sw       x12, 28(t3)
  sw       x13, 32(t3)
  sw       x14, 36(t3)
  sw       x15, 40(t3)  
  // restore the original values of s0 and s1
  lw       s0,   0(sp)
  lw       s1,   4(sp)
  addi     sp, sp, 8  
  ret

.global sec_zhi_test_asm

sec_zhi_test_asm:
  // s2-s11 (x18-x27) are callee-saved     
  addi     sp, sp, -40
  sw       s2,   0(sp)
  sw       s3,   4(sp)
  sw       s4,   8(sp)
  sw       s5,  12(sp)
  sw       s6,  16(sp)
  sw       s7,  20(sp)
  sw       s8,  24(sp)
  sw       s9,  28(sp)
  sw       s10, 32(sp)
  sw       s11, 36(sp)
  // initialize x16-x31 to be non-0
  li       x16, 16
  li       x17, 17
  li       x18, 18
  li       x19, 19
  li       x20, 20
  li       x21, 21
  li       x22, 22
  li       x23, 23
  li       x24, 24
  li       x25, 25
  li       x26, 26
  li       x27, 27
  li       x28, 28
  li       x29, 29
  li       x30, 30
  li       x31, 31
  // erase x16-x31 (0xFFFF = 0b 1111 1111 1111 1111)
  sec.zhi  0xFFFF     
  // store the values of x16-x31 for printing  
  sw       x16,  0(a0)   
  sw       x17,  4(a0)   
  sw       x18,  8(a0)
  sw       x19, 12(a0)
  sw       x20, 16(a0)
  sw       x21, 20(a0)
  sw       x22, 24(a0)
  sw       x23, 28(a0)
  sw       x24, 32(a0)
  sw       x25, 36(a0) 
  sw       x26, 40(a0)   
  sw       x27, 44(a0)   
  sw       x28, 48(a0)
  sw       x29, 52(a0)
  sw       x30, 56(a0)
  sw       x31, 60(a0) 
  // restore the original values of s2-s11
  lw       s2,   0(sp)
  lw       s3,   4(sp)
  lw       s4,   8(sp)
  lw       s5,  12(sp)
  lw       s6,  16(sp)
  lw       s7,  20(sp)
  lw       s8,  24(sp)
  lw       s9,  28(sp)
  lw       s10, 32(sp)
  lw       s11, 36(sp)
  addi     sp, sp, 40
  ret

// instruction latency measurement

.global sec_insn_latency_measurement_asm
sec_insn_latency_measurement_asm: 
  // `sec.and`
  read_cycle t0 
  sec.and    t2, t3, t4 
  read_cycle t1
  sub        t0, t1, t0 
  addi       t0, t0, -1  // `csrr` itself takes 1 cycle, which needs to be subtracted
  sw         t0,  0(a0)

  // `sec.andi`
  read_cycle t0 
  sec.andi   t2, t3, 0x0FF 
  read_cycle t1
  sub        t0, t1, t0 
  addi       t0, t0, -1  // `csrr` itself takes 1 cycle, which needs to be subtracted
  sw         t0,  4(a0) 

  // `sec.or`
  read_cycle t0 
  sec.or     t2, t3, t4 
  read_cycle t1
  sub        t0, t1, t0 
  addi       t0, t0, -1  // `csrr` itself takes 1 cycle, which needs to be subtracted
  sw         t0,  8(a0) 

  // `sec.ori`
  read_cycle t0 
  sec.ori    t2, t3, 0x0FF 
  read_cycle t1
  sub        t0, t1, t0 
  addi       t0, t0, -1  // `csrr` itself takes 1 cycle, which needs to be subtracted
  sw         t0, 12(a0) 

  // `sec.xor`
  read_cycle t0 
  sec.xor    t2, t3, t4 
  read_cycle t1
  sub        t0, t1, t0 
  addi       t0, t0, -1  // `csrr` itself takes 1 cycle, which needs to be subtracted
  sw         t0, 16(a0) 

  // `sec.xori`
  read_cycle t0 
  sec.xori   t2, t3, 0x0FF 
  read_cycle t1
  sub        t0, t1, t0 
  addi       t0, t0, -1  // `csrr` itself takes 1 cycle, which needs to be subtracted
  sw         t0, 20(a0)

  // `sec.slli`
  read_cycle t0 
  sec.slli   t2, t3, 4 
  read_cycle t1
  sub        t0, t1, t0 
  addi       t0, t0, -1  // `csrr` itself takes 1 cycle, which needs to be subtracted
  sw         t0, 24(a0)

  // `sec.srli`
  read_cycle t0 
  sec.srli   t2, t3, 4 
  read_cycle t1
  sub        t0, t1, t0 
  addi       t0, t0, -1  // `csrr` itself takes 1 cycle, which needs to be subtracted
  sw         t0, 28(a0)

  // `sec.sw`
  read_cycle t0 
  sec.sw     t2, a0, 32, 0 
  read_cycle t1
  sub        t0, t1, t0 
  addi       t0, t0, -1  // `csrr` itself takes 1 cycle, which needs to be subtracted
  sw         t0, 32(a0)

  // `sec.lw`
  read_cycle t0 
  sec.lw     t2, a0, 36, 1 
  read_cycle t1
  sub        t0, t1, t0 
  addi       t0, t0, -1  // `csrr` itself takes 1 cycle, which needs to be subtracted
  sw         t0, 36(a0)

  // `sec.zlo`
  read_cycle t0 
  sec.zlo    0x000 
  read_cycle t1
  sub        t0, t1, t0
  addi       t0, t0, -1  // `csrr` itself takes 1 cycle, which needs to be subtracted
  sw         t0, 40(a0)

  // `sec.zhi`
  read_cycle t0 
  sec.zhi    0x000 
  read_cycle t1
  sub        t0, t1, t0 
  addi       t0, t0, -1  // `csrr` itself takes 1 cycle, which needs to be subtracted
  sw         t0, 44(a0)

  ret

