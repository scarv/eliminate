# eLIMInate: a Leakage-focused ISE for Masked Implementation

[Ibex core](https://github.com/lowRISC/ibex) serves as the host core for this
work. All the modifications to the original Ibex core (RTL files) are well
annotated with `// ++ eliminate` and `// -- eliminate`, which facilitates the
check by users. 

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

    - Copy all the files in `src/[area/latency]/hw/` and replace the original files in `extern/ibex-demo-system/vendor/lowrisc_ibex/rtl/`.

    - Copy the software micro-benchmark folder `src/[area/latency]/sw`, and paste it to `extern/ibex-demo-system/sw/demo/` and rename it to `eliminate`.

    - Enter `extern/ibex-demo-system/`.

    - Edit the file `sw/demo/CMakeLists.txt` to add `add_subdirectory(eliminate)`.

    - Edit the file `sw/CMakeLists.txt` to enable the support for assembler code (which is used in micro-benchmarks), i.e., adding `enable_language(ASM)` and `set(CMAKE_ASM_COMPILER riscv32-unknown-elf-gcc)`.

    - Config the file `rtl/system/ibex_demo_system.sv` to use a flipflop-based register file (i.e., at line 228 modifying `ibex_pkg::RegFileFPGA` to `ibex_pkg::RegFileFF`).

    - For the latency-optimised implementation, edit the file `vendor/lowrisc_ibex/ibex_core.core` to add `- rtl/ibex_lsm_generator.sv` and `- rtl/keccak_f100_2rounds.sv` under the section `filesets:files_rtl:files`, and edit the file `vendor/lowrisc_ibex/ibex_pkg.core` to add `- rtl/keccak_pkg.sv` under the section `filesets:files_rtl:files`.

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

### Security evaluation 

The security evaluation (i.e., no leakage stemming from overwriting) of ISE is done by using [Coco](https://github.com/IAIK/coco-alma) (i.e., `extern/coco-alma` and `extern/coco-ibex`). 

- User can choose either a manual modification or using the patch to apply the change to 
[Coco-Ibex core](https://github.com/IAIK/coco-ibex) and [CoCoAlma](https://github.com/IAIK/coco-alma):

  - Manual modification

    - Copy all the files in `src/[area/latency]/coco/hw/` and replace the original files in `extern/coco-ibex/rtl/`.
    
    - Copy the software micro-benchmark folder `src/[area/latency]/coco/sw`, and paste it to `extern/coco-alma/examples/ibex/programs/` and rename it to `eliminate`.

    - Copy the label file `src/[area/latency]/coco/eliminate_label.txt`, and paste it to `extern/coco-alma/examples/ibex/labels/`.

    - Enter `extern/coco-alma` and follow the instructions of `README.md` to 
      - parse the core 
      - compile the micro-benchmark
      - generate the execution trace  
      - verify security of custom secure instruction 

  - Using the patch 
    - **TBA**  

<!--- ==================================================================== --->
