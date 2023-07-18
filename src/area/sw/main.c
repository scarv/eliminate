// computational correctness test and latency measurement for custom secure instructions

#include "demo_system.h"  // header file of this demo system 
#include "gpio.h"         // header file of General-Purpose Input/Output (GPIO)
#include "timer.h"        // header file of timer 
#include <stdbool.h>      // header file of bool type 


// prototypes of micro-benchmarks 

// class-1
extern void sec_and_test_asm(uint32_t *r, uint32_t *a, uint32_t *b);
extern void sec_andi_test_asm(uint32_t *r, uint32_t *a);
extern void sec_or_test_asm(uint32_t *r, uint32_t *a, uint32_t *b);
extern void sec_ori_test_asm (uint32_t *r, uint32_t *a);
extern void sec_xor_test_asm(uint32_t *r, uint32_t *a, uint32_t *b);
extern void sec_xori_test_asm(uint32_t *r, uint32_t *a);
extern void sec_slli_test_asm(uint32_t *r, uint32_t *a);
extern void sec_srli_test_asm(uint32_t *r, uint32_t *a);
extern void sec_add_test_asm(uint32_t *r, uint32_t *a, uint32_t *b);
extern void sec_sub_test_asm(uint32_t *r, uint32_t *a, uint32_t *b);

// class-2 
extern void sec_lw_test_asm(uint32_t *r);
extern void sec_sw_test_asm(uint32_t *r);
extern void sec_lbu_test_asm(uint32_t *r);
extern void sec_sb_test_asm(uint32_t *r);

// instruction latency measurement
extern void sec_insn_latency_measurement_asm(uint32_t *r);


void test_uart_irq_handler(void) __attribute__((interrupt));

void test_uart_irq_handler(void) {
  int uart_in_char;

  while ((uart_in_char = uart_in(DEFAULT_UART)) != -1) {
    uart_out(DEFAULT_UART, uart_in_char);
    uart_out(DEFAULT_UART, '\r');
    uart_out(DEFAULT_UART, '\n');
  }
}

// main function  
int main()
{
  install_exception_handler(UART_IRQ_NUM, &test_uart_irq_handler);
  uart_enable_rx_int(); // enable uart receiver

  // initialize the timer (time_base = 10e9, i.e., the interval)
  timer_init();
  timer_enable(1000000000); 
  // to execute the first test fast
  uint64_t last_elapsed_time = -1;

  while (1) {
    uint64_t cur_time = get_elapsed_time();

    if (cur_time != last_elapsed_time) {
      last_elapsed_time = cur_time;

      // disable interrupts whilst outputting to prevent output for RX IRQ
      // happening in the middle
      set_global_interrupt_enable(0);

      // variables for custom secure instructions test 
      uint32_t a = 0x01234567UL, b = 0x0F0F0F0FUL, r, x[16];

      // execute the micro-benchmarks and print the results
      puts("*******************************************\n");
      puts("computational correctness test: \n");
      puts("-------------------------------------------\n");
      puts("class-1 test: \n");
      puts("-------------------------------------------\n");
      puts("operands        a = 01234567 \n");
      puts("                b = 0F0F0F0F \n");
      puts("-------------------------------------------\n");
      puts("sec.and  test:  r = a & b \n");
      r = 0xFFFFFFFFUL;
      puts("current         r = ");
      puthex(r);
      putchar('\n');
      puts("expected result r = 01030507 \n");
      sec_and_test_asm(&r, &a, &b);
      puts("obtained result r = "); 
      puthex(r);
      putchar('\n');
      puts("-------------------------------------------\n");
      puts("sec.andi test:  r = a & EXTS(0FF) \n");
      r = 0xFFFFFFFFUL;
      puts("current         r = ");
      puthex(r);
      putchar('\n');
      puts("expected result r = 00000067 \n");
      sec_andi_test_asm(&r, &a);
      puts("obtained result r = "); 
      puthex(r);
      putchar('\n');
      puts("-------------------------------------------\n");
      puts("sec.or   test:  r = a | b \n");
      r = 0xFFFFFFFFUL;
      puts("current         r = ");
      puthex(r);
      putchar('\n');
      puts("expected result r = 0F2F4F6F \n");
      sec_or_test_asm(&r, &a, &b);
      puts("obtained result r = "); 
      puthex(r);
      putchar('\n');
      puts("-------------------------------------------\n");
      puts("sec.ori  test:  r = a | EXTS(0FF) \n");
      r = 0xFFFFFFFFUL;
      puts("current         r = ");
      puthex(r);
      putchar('\n');
      puts("expected result r = 012345FF \n");
      sec_ori_test_asm(&r, &a);
      puts("obtained result r = "); 
      puthex(r);
      putchar('\n');
      puts("-------------------------------------------\n");
      puts("sec.xor  test:  r = a ^ b \n");
      r = 0xFFFFFFFFUL;
      puts("current         r = ");
      puthex(r);
      putchar('\n');
      puts("expected result r = 0E2C4A68 \n");
      sec_xor_test_asm(&r, &a, &b);
      puts("obtained result r = "); 
      puthex(r);
      putchar('\n');
      puts("-------------------------------------------\n");
      puts("sec.xori test:  r = a ^ EXTS(FFF) = ~a \n");
      r = 0xFFFFFFFFUL;
      puts("current         r = ");
      puthex(r);
      putchar('\n');
      puts("expected result r = FEDCBA98 \n");
      sec_xori_test_asm(&r, &a);
      puts("obtained result r = "); 
      puthex(r);
      putchar('\n');
      puts("-------------------------------------------\n");
      puts("sec.slli test:  r = a << 4 \n");
      r = 0xFFFFFFFFUL;
      puts("current         r = ");
      puthex(r);
      putchar('\n');
      puts("expected result r = 12345670 \n");
      sec_slli_test_asm(&r, &a);
      puts("obtained result r = "); 
      puthex(r);
      putchar('\n');
      puts("-------------------------------------------\n");
      puts("sec.srli test:  r = a >> 4 \n");
      r = 0xFFFFFFFFUL;
      puts("current         r = ");
      puthex(r);
      putchar('\n');
      puts("expected result r = 00123456 \n");
      sec_srli_test_asm(&r, &a);
      puts("obtained result r = "); 
      puthex(r);
      putchar('\n');
      puts("-------------------------------------------\n");
      puts("sec.add  test:  r = a + b \n");
      r = 0xFFFFFFFFUL;
      puts("current         r = ");
      puthex(r);
      putchar('\n');
      puts("expected result r = 10325476 \n");
      sec_add_test_asm(&r, &a, &b);
      puts("obtained result r = "); 
      puthex(r);
      putchar('\n');
      puts("-------------------------------------------\n");
      puts("sec.sub  test:  r = a - b \n");
      r = 0xFFFFFFFFUL;
      puts("current         r = ");
      puthex(r);
      putchar('\n');
      puts("expected result r = F2143658 \n");
      sec_sub_test_asm(&r, &a, &b);
      puts("obtained result r = "); 
      puthex(r);
      putchar('\n');
      puts("-------------------------------------------\n");
      puts("class-2 test: \n");
      puts("-------------------------------------------\n");
      puts("sec.sw   test: \n");
      x[0] = x[1] = x[2] = x[3] = 0xFFFFFFFFUL;
      puts("current        x[0] = ");
      puthex(x[0]);
      putchar('\n');
      puts("current        x[1] = ");
      puthex(x[1]);
      putchar('\n');
      puts("current        x[2] = ");
      puthex(x[2]);
      putchar('\n');
      puts("current        x[3] = ");
      puthex(x[3]);
      putchar('\n');
      puts("expected       x[0] = 01234567 \n");
      puts("expected       x[1] = 89ABCDEF \n");
      puts("expected       x[2] = 01234567 \n");
      puts("expected       x[3] = 89ABCDEF \n");
      sec_sw_test_asm(x);
      puts("obtained       x[0] = "); 
      puthex(x[0]);
      putchar('\n');
      puts("obtained       x[1] = "); 
      puthex(x[1]);
      putchar('\n');
      puts("obtained       x[2] = "); 
      puthex(x[2]);
      putchar('\n');
      puts("obtained       x[3] = "); 
      puthex(x[3]);
      putchar('\n');
      puts("-------------------------------------------\n");
      puts("sec.lw   test: \n");
      x[0] = x[1] = x[2] = x[3] = 0xFFFFFFFFUL;
      puts("current        x[0] = ");
      puthex(x[0]);
      putchar('\n');
      puts("current        x[1] = ");
      puthex(x[1]);
      putchar('\n');
      puts("current        x[2] = ");
      puthex(x[2]);
      putchar('\n');
      puts("current        x[3] = ");
      puthex(x[3]);
      putchar('\n');
      puts("expected       x[0] = 01234567 \n");
      puts("expected       x[1] = 89ABCDEF \n");
      puts("expected       x[2] = 01234567 \n");
      puts("expected       x[3] = 89ABCDEF \n");
      sec_lw_test_asm(x);
      puts("obtained       x[0] = "); 
      puthex(x[0]);
      putchar('\n');
      puts("obtained       x[1] = "); 
      puthex(x[1]);
      putchar('\n');
      puts("obtained       x[2] = "); 
      puthex(x[2]);
      putchar('\n');
      puts("obtained       x[3] = "); 
      puthex(x[3]);
      putchar('\n');
      puts("-------------------------------------------\n");
      puts("sec.sb   test: \n");
      x[0] = x[1] = x[2] = x[3] = 0xFFFFFFFFUL;
      puts("current        x[0] = ");
      puthex(x[0]);
      putchar('\n');
      puts("current        x[1] = ");
      puthex(x[1]);
      putchar('\n');
      puts("current        x[2] = ");
      puthex(x[2]);
      putchar('\n');
      puts("current        x[3] = ");
      puthex(x[3]);
      putchar('\n');
      puts("expected       x[0] = FFFFFF67 \n");
      puts("expected       x[1] = FFFFFFEF \n");
      puts("expected       x[2] = FFFFFF67 \n");
      puts("expected       x[3] = FFFFFFEF \n");
      sec_sb_test_asm(x);
      puts("obtained       x[0] = "); 
      puthex(x[0]);
      putchar('\n');
      puts("obtained       x[1] = "); 
      puthex(x[1]);
      putchar('\n');
      puts("obtained       x[2] = "); 
      puthex(x[2]);
      putchar('\n');
      puts("obtained       x[3] = "); 
      puthex(x[3]);
      putchar('\n');
      puts("-------------------------------------------\n");
      puts("sec.lbu  test: \n");
      puts("current        x[0] = ");
      puthex(x[0]);
      putchar('\n');
      puts("current        x[1] = ");
      puthex(x[1]);
      putchar('\n');
      puts("current        x[2] = ");
      puthex(x[2]);
      putchar('\n');
      puts("current        x[3] = ");
      puthex(x[3]);
      putchar('\n');
      puts("expected       x[0] = 00000067 \n");
      puts("expected       x[1] = 000000EF \n");
      puts("expected       x[2] = 00000067 \n");
      puts("expected       x[3] = 000000EF \n");
      sec_lbu_test_asm(x);
      puts("obtained       x[0] = "); 
      puthex(x[0]);
      putchar('\n');
      puts("obtained       x[1] = "); 
      puthex(x[1]);
      putchar('\n');
      puts("obtained       x[2] = "); 
      puthex(x[2]);
      putchar('\n');
      puts("obtained       x[3] = "); 
      puthex(x[3]);
      putchar('\n');
      puts("-------------------------------------------\n");
      puts("instruction latency measurement: \n");
      puts("-------------------------------------------\n");   
      for (int i = 0; i < 16; i++) x[i] = 0;
      sec_insn_latency_measurement_asm(x);
      puts("sec.and       takes   "); 
      puthex(x[0]);
      puts(" cycles \n");
      puts("sec.andi      takes   "); 
      puthex(x[1]);
      puts(" cycles \n");
      puts("sec.or        takes   "); 
      puthex(x[2]);
      puts(" cycles \n");
      puts("sec.ori       takes   "); 
      puthex(x[3]);
      puts(" cycles \n");
      puts("sec.xor       takes   "); 
      puthex(x[4]);
      puts(" cycles \n");
      puts("sec.xori      takes   "); 
      puthex(x[5]);
      puts(" cycles \n");
      puts("sec.slli      takes   "); 
      puthex(x[6]);
      puts(" cycles \n");
      puts("sec.srli      takes   "); 
      puthex(x[7]);
      puts(" cycles \n");
      puts("sec.add       takes   "); 
      puthex(x[8]);
      puts(" cycles \n");
      puts("sec.sub       takes   "); 
      puthex(x[9]);
      puts(" cycles \n");
      puts("sec.sw        takes   "); 
      puthex(x[10]);
      puts(" cycles \n");
      puts("sec.lw        takes   "); 
      puthex(x[11]);
      puts(" cycles \n");
      puts("sec.sb        takes   "); 
      puthex(x[12]);
      puts(" cycles \n");
      puts("sec.lb        takes   "); 
      puthex(x[13]);
      puts(" cycles \n");
      puts("-------------------------------------------\n");
      puts("ended! \n");
      puts("*******************************************\n\n");
      
      // re-enable interrupts with output complete
      set_global_interrupt_enable(1);
    }
  }

  return 0;
}
