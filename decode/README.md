# Decode RTL

This directory contains the bandwidth-oriented overlay used for autoregressive single-token inference. It combines multi-channel DMA, streaming W4A16/W8A16 GEMV, and model-specific post-processing for SmolVLM2.

## Entry Points

- Integration wrapper: `rtl/top/kv260_npu_generic_wrapper.v`
- AXI-facing top: `rtl/top/T_NPU_FPGA.sv`
- Core composition: `rtl/top/T_NPU.sv`
- Model flow: `rtl/top/smolvlm2_decode.sv`
- Source inventory: `rtl/top.files`

Paths in `rtl/top.files` are relative to `decode/rtl/`. Supplemental `*.files` lists describe smaller configurations but are not a supported end-to-end build flow.

## Directory Guide

| Path | Purpose |
| --- | --- |
| `rtl/config/` | Decode configuration package |
| `rtl/npu/dma/` | Four-channel AXI movement and buffering |
| `rtl/npu/gemv/` | W4A16/W8A16 streaming GEMV and FP arithmetic |
| `rtl/npu/flow/` | Decode descriptors, scheduling, stream buffers, and KV writers |
| `rtl/npu/sfu/` | RoPE, softmax, SiLU/GELU, layer norm, transpose, and postprocess |
| `rtl/npu/spm/` | Scratchpad implementations and banking |
| `rtl/npu/systolic_array/` | Legacy/configurable array path |
| `rtl/npu/quant/` | Integer/fixed-point/FP conversion helpers |
| `rtl/utils/` | FIFO, multiplier, divider, DRAM simulation, and portable SRAM models |
| `rtl/top/` | AXI wrappers and system composition |

## Data Formats

| Path | Format |
| --- | --- |
| Decode GEMV | INT4 or INT8 weights with FP16 activations (W4A16/W8A16) |
| Accumulation/postprocess | FP32/FP16 as selected by the sub-pipeline |
| RoPE and SiLU/SwiGLU | FP16 stream |
| QK/PV | KV cache consumed as GEMV weight payload; online softmax in postprocess |
| KV cache | INT8 data plus FP16 scale per token and KV head (64 dimensions) |
| AXI memory | four 128-bit master ports |
| Control | 64-bit AXI4-Lite data |

The flow is specialized for hidden size 960, 15 query heads, 5 KV heads, head dimension 64, and GQA group size 3.

## Relation to Prefill

Decode begins after the host has completed prefill, persisted shared state in DDR, and loaded this overlay. It reuses the common control/interrupt style but has stage-specific stream descriptors and cache layouts. The software at the pinned companion revision owns the transition.

The archived board configuration targeted approximately 200 MHz. This cleanup only replaces restricted helpers with portable RTL and performs interface/syntax checks; it does not rerun Vivado implementation or board regression.
