// computational correctness test for custom secure instructions

#include "demo_system.h"  // header file of this demo system 
#include "gpio.h"         // header file of General-Purpose Input/Output (GPIO)
#include "timer.h"        // header file of timer 
#include <stdbool.h>      // header file of bool type 

// class-1
extern void sec_and_test_asm(uint32_t *r, uint32_t *a, uint32_t *b);
extern void sec_or_test_asm (uint32_t *r, uint32_t *a, uint32_t *b);
extern void sec_xor_test_asm(uint32_t *r, uint32_t *a, uint32_t *b);
extern void sec_slli_test_asm(uint32_t *r, uint32_t *a);
extern void sec_srli_test_asm(uint32_t *r, uint32_t *a);

// class-2 
extern void sec_sw_test_asm(uint32_t *r);
extern void sec_lw_test_asm(uint32_t *r);

// class-3
extern void sec_zlo_test_asm(uint32_t *r);
extern void sec_zhi_test_asm(uint32_t *r);


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

  // variables for custom secure instructions test 
  uint32_t a = 0x01234567UL, b = 0x0F0F0F0FUL, r, x[16];

  while (1) {
    uint64_t cur_time = get_elapsed_time();

    if (cur_time != last_elapsed_time) {
      last_elapsed_time = cur_time;

      // disable interrupts whilst outputting to prevent output for RX IRQ
      // happening in the middle
      set_global_interrupt_enable(0);

      // print the prologue to uart 
      puts("*******************************************\n");
      puts("custom secure instructions test: \n");
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
      puts("class-3 test: \n");
      puts("-------------------------------------------\n");
      puts("sec.zlo  test:  erase x5-x15  \n");
      for (int i = 0; i < 16; i++) x[i] = 0xFFFFFFFFUL;
      puts("current x5-x15  all = "); 
      puthex(x[0]);
      putchar('\n');
      sec_zlo_test_asm(x);
      puts("obtained result x5  = "); 
      puthex(x[0]);
      putchar('\n');
      puts("obtained result x6  = "); 
      puthex(x[1]);
      putchar('\n');
      puts("obtained result x7  = "); 
      puthex(x[2]);
      putchar('\n');
      puts("obtained result x8  = "); 
      puthex(x[3]);
      putchar('\n');
      puts("obtained result x9  = "); 
      puthex(x[4]);
      putchar('\n');
      puts("obtained result x10 = "); 
      puthex(x[5]);
      putchar('\n');
      puts("obtained result x11 = "); 
      puthex(x[6]);
      putchar('\n');
      puts("obtained result x12 = "); 
      puthex(x[7]);
      putchar('\n');
      puts("obtained result x13 = "); 
      puthex(x[8]);
      putchar('\n');
      puts("obtained result x14 = "); 
      puthex(x[9]);
      putchar('\n');
      puts("obtained result x15 = "); 
      puthex(x[10]);
      putchar('\n');
      puts("-------------------------------------------\n");
      puts("sec.zhi  test:  erase x16-x31  \n");
      for (int i = 0; i < 16; i++) x[i] = 0xFFFFFFFFUL;
      puts("current x16-x31 all = "); 
      puthex(x[0]);
      putchar('\n');
      sec_zhi_test_asm(x);
      puts("obtained result x16 = "); 
      puthex(x[0]);
      putchar('\n');
      puts("obtained result x17 = "); 
      puthex(x[1]);
      putchar('\n');
      puts("obtained result x18 = "); 
      puthex(x[2]);
      putchar('\n');
      puts("obtained result x19 = "); 
      puthex(x[3]);
      putchar('\n');
      puts("obtained result x20 = "); 
      puthex(x[4]);
      putchar('\n');
      puts("obtained result x21 = "); 
      puthex(x[5]);
      putchar('\n');
      puts("obtained result x22 = "); 
      puthex(x[6]);
      putchar('\n');
      puts("obtained result x23 = "); 
      puthex(x[7]);
      putchar('\n');
      puts("obtained result x24 = "); 
      puthex(x[8]);
      putchar('\n');
      puts("obtained result x25 = "); 
      puthex(x[9]);
      putchar('\n');
      puts("obtained result x26 = "); 
      puthex(x[10]);
      putchar('\n');
      puts("obtained result x27 = "); 
      puthex(x[11]);
      putchar('\n');
      puts("obtained result x28 = "); 
      puthex(x[12]);
      putchar('\n');
      puts("obtained result x29 = "); 
      puthex(x[13]);
      putchar('\n');
      puts("obtained result x30 = "); 
      puthex(x[14]);
      putchar('\n');
      puts("obtained result x31 = "); 
      puthex(x[15]);
      putchar('\n');
      puts("-------------------------------------------\n");
      puts("test ended! \n");
      puts("*******************************************\n\n");
      // re-enable interrupts with output complete
      set_global_interrupt_enable(1);
    }
  }

  return 0;
}
