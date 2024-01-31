# Use Coco for vanilla Ibex 

The [README](../../../../README.md#security-evaluation) at the top level of the
repo introduces how to perform the security evaluation with Coco formal
verification framework. However, the associated [RTL files](../hw/) are based on
CocoIbex. This document provides the instructions about how to use Coco for
vanilla Ibex and therefore for the original [eLIMInate RTL files](../../hw/). 

## Instruction (LO version)

1. Copy all the files in `eliminate/src/latency/hw/` and replace the original
   files in `eliminate/extern/coco-ibex/rtl/`.

2. Delete the file `eliminate/extern/coco-ibex/rtl/ibex_top.sv`, because it will
   use a modified and compatible one.

3. Copy `eliminate/src/latency/coco/vanilla/dv_fcov_macros.svh` and paste it to
   `eliminate/extern/coco-ibex/rtl/`.

4. Copy `eliminate/src/latency/coco/vanilla/ibex_top.v` and paste it to
   `eliminate/extern/coco-ibex/shared/rtl/` to replace the original `ibex_top.v`
   file.

5. Copy the software micro-benchmark folder `eliminate/src/latency/coco/sw`, and
   paste it to `eliminate/extern/coco-alma/examples/ibex/programs/` and rename
   it to `eliminate`.

6. Copy the **new** label file
   `eliminate/src/latency/coco/vanilla/eliminate_label.txt`, and paste it to
   `eliminate/extern/coco-alma/examples/ibex/labels/`.

7. Enter `eliminate/extern/coco-alma` and follow the instructions of `README.md`
   to 
    - parse the core 
    - compile the micro-benchmark
    - generate the execution trace  
    - verify security of custom secure instruction 
