# eLIMInate: a Leakage-aware ISE for Masked Implementation

[Ibex core](https://github.com/lowRISC/ibex) is served as the host core for this work.
All the modifications to the original Ibex core (RTL files) are well-marked with
`// ++ eliminate` and `// -- eliminate`, which facilitates 
the check by users. 

<!--- ==================================================================== --->

## Organisation
```
├── doc                     - documentation
├── extern                  - external submodules
└── src                     - source code
    ├── area                  - source code for area-optimised version 
    │   ├── coco                - source code for security evaluation with coco     
    │   ├── hw                  - source code for hardware (i.e., ISE implementation)
    │   └── sw                  - source code for software (i.e., micro-benchmarks)
    └── latency               - source code for latency-optimised version
        ├── coco                - source code for security evaluation with coco     
        ├── hw                  - source code for hardware (i.e., ISE implementation)
        └── sw                  - source code for software (i.e., micro-benchmarks)
```

<!--- ==================================================================== --->

## Usage

### Performance evaluation

The performance evaluation of ISE is done with using [Ibex Demo System](https://github.com/lowRISC/ibex-demo-system) (i.e., `extern/ibex-demo-system`) which comprises the Ibex core.

- User can choose either a manual modification or using the patch to apply the change to Ibex core:

  - Manual modification

    - Copy all the files in `src/[area/lantecy]/hw/` and replace the original files in `extern/ibex-demo-system/vendor/lowrisc_ibex/rtl/`.

    - Copy the software micro-benchmark folder `src/[area/lantecy]/sw`, and paste it to `extern/ibex-demo-system/sw/demo/` and rename it to `eliminate`.

    - Enter `extern/ibex-demo-system/`.

    - Edit the file `sw/demo/CMakeLists.txt` to add `add_subdirectory(eliminate)`.

    - Edit the file `sw/CMakeLists.txt` to enable the support for assembler code (which is used in micro-benchmarks), i.e., adding `enable_language(ASM)` and `set(CMAKE_ASM_COMPILER riscv32-unknown-elf-gcc)`.

    - Config the file `rtl/system/ibex_demo_system.sv` to use a flipflop-based register file (i.e., at line 228 modifying `ibex_pkg::RegFileFPGA` to `ibex_pkg::RegFileFF`).

  - Using the patch

    - **TBA**

- Enter `extern/ibex-demo-system/` and follow the instructions of `README.md` to 
  - install all the required tools and packages;
  - build the software (i.e., the micro-benchmarks);
  -  a) FPGA-option: build FPGA bitstream + program FPGA + load application; 

     or

     b) simulation-option: build simulator + run the simulator + get the FST trace.

- Computational correctness test

  a) FPGA-option: view the output of loaded application via `screen`.

  b) simulation-option (recommanded): view the signals of the collected FST trace in `gtkwave`. 

- Latency measurement

  a) FPGA-option: use `rdcycle` instruction. 

  b) simulation-option: view the signals in `gtkwave` (e.g., with the help of `clk_i`).

- Hardware overhead measurement

  a) FPGA-option (only): check the vivado ultilisation report.

### Security evaluation 

The security evaluation of ISE is done by using [coco](https://github.com/IAIK/coco-alma) tool 
(i.e., `extern/coco-alma` and `extern/coco-ibex`).
**TBA**.

<!--- ==================================================================== --->

## Working status re. instruction evaluation

### Area-optimised version 

| Instructions | Computation | Security | Latency | 
| :----------: | :---------: | :------: | :-----: |
| `sec.and`    |     &check; |  &check; |       2 |
| `sec.andi`   |     &check; |          |       2 |
| `sec.or`     |     &check; |  &check; |       2 |
| `sec.ori`    |     &check; |          |       2 |
| `sec.xor`    |     &check; |  &check; |       2 |
| `sec.xori`   |     &check; |          |       2 |
| `sec.lw`     |     &check; |          |       6 |
| `sec.sw`     |     &check; |          |       4 |
| `sec.zlo`    |     &check; |          |       1 |
| `sec.zhi`    |     &check; |          |       1 |

### Latency-optimised version 

| Instructions | Computation | Security | Latency | 
| :----------: | :---------: | :------: | :-----: |
| `sec.and`    |     &check; |          |       1 |
| `sec.andi`   |     &check; |          |       1 |
| `sec.or`     |     &check; |          |       1 |
| `sec.ori`    |     &check; |          |       1 |
| `sec.xor`    |     &check; |          |       1 |
| `sec.xori`   |     &check; |          |       1 |
| `sec.lw`     |     &check; |          |       1 |
| `sec.sw`     |     &check; |          |       1 |
| `sec.zlo`    |     &check; |          |       1 |
| `sec.zhi`    |     &check; |          |       1 |

<!--- ==================================================================== --->
