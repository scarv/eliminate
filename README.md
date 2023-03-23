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
    │   ├── coco                - source code for non-leakage evaluation with coco     
    │   ├── hw                  - source code for hardware (i.e., ISE implementation)
    │   └── sw                  - source code for software (i.e., micro-benchmarks)
    └── latency               - source code for latency-optimised version
        ├── coco                - source code for non-leakage evaluation with coco     
        ├── hw                  - source code for hardware (i.e., ISE implementation)
        └── sw                  - source code for software (i.e., micro-benchmarks)
```

<!--- ==================================================================== --->

## Usage

### Performance evaluation

The performance evaluation of ISE is done with using [Ibex Demo System](https://github.com/lowRISC/ibex-demo-system) (i.e., `extern/ibex-demo-system`) which comprises the Ibex core.

- User can choose either a manual modification or using the patch to apply the change to Ibex core:

  - Manual modification

    - Copy all the files in `src/[area/latency]/hw/` and replace the original files in `extern/ibex-demo-system/vendor/lowrisc_ibex/rtl/`.

    - Copy the software micro-benchmark folder `src/[area/latency]/sw`, and paste it to `extern/ibex-demo-system/sw/demo/` and rename it to `eliminate`.

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

  a) FPGA-option (recommended for latency-optmised version): view the output of loaded application via `screen`.

  b) simulation-option (recommended for area-optimised version): view the signals of the collected FST trace in `gtkwave`. 

- Latency measurement

  a) FPGA-option: view the output of loaded application via `screen`.

  b) simulation-option: view the signals in `gtkwave` (e.g., with the help of `clk_i`).

- Hardware overhead measurement

  a) FPGA-option (only): check the vivado GUI report ultilisation.

### Non-leakage evaluation 

The non-leakage evaluation of ISE is done by using [Coco](https://github.com/IAIK/coco-alma) (i.e., `extern/coco-alma` and `extern/coco-ibex`). 

- User can choose either a manual modification or using the patch to apply the change to 
[Coco-Ibex core](https://github.com/IAIK/coco-ibex) and [CoCoAlma](https://github.com/IAIK/coco-alma):

  - Manual modification

    - Copy all the files in `src/[ara/latency]/coco/hw/` and replace the original files in `extern/coco-ibex/rtl/`.
    
    - Copy the software micro-benchmark folder `src/[area/latency]/coco/sw`, and paste it to `extern/coco-alma/examples/ibex/programs/` and rename it to `eliminate`.

    - Copy the label file `src/[area/latency]/coco/eliminate_label.txt`, and paste it to `extern/coco-alma/examples/ibex/labels/`.

    - Enter `extern/coco-alma` and follow the instructions of `README.md` to 
      - parse the core 
      - compile the micro-benchmark
      - generate the execution trace  
      - verify non-leakage of custom secure instruction 

  - Using the patch 
    - **TBA**  

<!--- ==================================================================== --->

## Instruction evaluation

### Area-optimised (AO) version 

| Instruction | Computation | Non-leakage | Latency | 
| :---------: | :---------: | :---------: | :-----: |
| `sec.and`   |     &check; |     &check; |      2  |
| `sec.andi`  |     &check; |     &check; |      2  |
| `sec.or`    |     &check; |     &check; |      2  |
| `sec.ori`   |     &check; |     &check; |      2  |
| `sec.xor`   |     &check; |     &check; |      2  |
| `sec.xori`  |     &check; |     &check; |      2  |
| `sec.slli`  |     &check; |     &check; |      2  |
| `sec.srli`  |     &check; |     &check; |      2  |
| `sec.lw`    |     &check; |     &check; |      6  |
| `sec.sw`    |     &check; |     &check; |      4  |
| `sec.zlo`   |     &check; |          -  |      1  |
| `sec.zhi`   |     &check; |          -  |      1  |

### Latency-optimised (LO) version 

| Instruction | Computation | Non-leakage | Latency | 
| :---------: | :---------: | :---------: | :-----: |
| `sec.and`   |     &check; |     &check; |      1  |
| `sec.andi`  |     &check; |     &check; |      1  |
| `sec.or`    |     &check; |     &check; |      1  |
| `sec.ori`   |     &check; |     &check; |      1  |
| `sec.xor`   |     &check; |     &check; |      1  |
| `sec.xori`  |     &check; |     &check; |      1  |
| `sec.slli`  |     &check; |     &check; |      1  |
| `sec.srli`  |     &check; |     &check; |      1  |
| `sec.lw`    |     &check; |     &check; |      2  |
| `sec.sw`    |     &check; |     &check; |      2  |
| `sec.zlo`   |     &check; |          -  |      1  |
| `sec.zhi`   |     &check; |          -  |      1  |

### Hardware overhead (Vivado 2022.2)

| Core                   |  Regs  |  LUTs  |  DSPs  | 
| :--------------------  | :----: | :----: | :----: |
| Ibex                   |  2364  |  3936  |    10  |
| Ibex + AO class-1      |  2361  |  3870  |    10  |
| Ibex + AO class-1+2    |  2366  |  3823  |    10  |
| Ibex + AO class-1+2+3  |  2366  |  4926  |    10  |
| Ibex + LO class-1      |  2585  |  5185  |    10  |
| Ibex + LO class-1+2    |  2713  |  5528  |    10  |
| Ibex + LO class-1+2+3  |  2745  |  7423  |    10  |

### Hardware overhead (Vivado 2019.1)

| Core                   |  Regs  |  LUTs  |  DSPs  | 
| :--------------------  | :----: | :----: | :----: |
| Ibex                   |  2363  |  3602  |    10  |
| Ibex + AO class-1      |  2365  |  3565  |    10  |
| Ibex + AO class-1+2    |  2365  |  3847  |    10  |
| Ibex + AO class-1+2+3  |  2366  |  4268  |    10  |
| Ibex + LO class-1      |        |        |    10  |
| Ibex + LO class-1+2    |        |        |    10  |
| Ibex + LO class-1+2+3  |        |        |    10  |

<!--- ==================================================================== --->
