# Prefill RTL

This directory contains the compute-dense overlay used for image projection and prompt prefill. It combines tiled W8A8 GEMM with attention-specialized QK and Log8 PV paths.

## Entry Points

- Integration wrapper: `rtl/ip/kv260_npu_generic_wrapper.sv`
- Packaged-IP shell: `rtl/ip/Versa_P_ip.v`
- AXI-facing top: `rtl/top/Versa_P.sv`
- Compute/control top: `rtl/top/Versa_P_core.sv`
- Source inventory: `filelists/versa_p_core.f`

The filelist paths are relative to `prefill/filelists/`. It inventories the core RTL but does not constitute a complete Vivado project or include all packaging/build metadata.

## Directory Guide

| Path | Purpose |
| --- | --- |
| `rtl/pkg/` | Configuration and scratchpad types/constants |
| `rtl/sa/` | 16x32/32x32 INT8 systolic arrays, PEs, skew and drain logic |
| `rtl/attention/` | Tiled QK scheduling, score scaling, and max metadata |
| `rtl/scheduler/` | GEMM/PV mode scheduling |
| `rtl/bank/` | BRAM/URAM-backed 256-bit scratchpad banks |
| `rtl/loader/` | 128-bit AXI beat to 256-bit scratchpad packing |
| `rtl/output/` | Accumulation, Log8 decode, normalization, and output conversion |
| `rtl/dma/` | AXI read/write engines and DMA routing |
| `rtl/ctrl/` | AXI4-Lite descriptors, status, IRQ, and bank ownership |
| `rtl/top/` | Datapath composition and external interfaces |
| `rtl/ip/` | KV260-facing wrapper and IP shell |

## Data Formats

| Path | Format |
| --- | --- |
| General GEMM | INT8 activation x INT8 weight -> INT32 accumulation |
| QK | INT8 Q/K, 64-element head dimension, scaled distance/max metadata |
| Attention probability | unsigned 8-bit Log8 numerator representation |
| PV | Log8 P decoded to fixed-point x INT8 V -> accumulated/normalized output |
| AXI memory | 128-bit beats |
| Scratchpad | 256-bit words |
| Control | 64-bit AXI4-Lite data |

## Relation to Decode

Prefill creates prompt state and the initial KV-cache content in DDR. The host waits for completion, switches to the decode overlay, and passes buffer/layout state to the companion runtime. There is no direct RTL-to-RTL connection between the two directories.

The archived board configuration reported approximately 190 MHz for this stage. This repository cleanup did not rerun compilation, synthesis, timing, or board validation.
