# Hardware Reference

## Target

| Item | Value |
| --- | --- |
| Board | AMD/Xilinx Kria KV260 Vision AI Starter Kit |
| FPGA part | `xck26-sfvc784-2LV-c` |
| Board part | `xilinx.com:kv260_som:part0:1.4` |
| Archived tool version | Vivado 2025.1 |
| Reported prefill clock | about 190 MHz |
| Reported decode clock | about 200 MHz |
| Archived control base | `0xA0000000`, 64 KiB range |

The archived wrappers carry separate `prefill_clk` and `decode_clk` ports. Only the active stage uses its compute clock. Reset is active low.

## RTL Entry Points

| Stage | Integration wrapper | Compute top | Source inventory |
| --- | --- | --- | --- |
| Prefill | `prefill/rtl/ip/kv260_npu_generic_wrapper.sv` | `prefill/rtl/top/Versa_P.sv` | `prefill/filelists/versa_p_core.f` |
| Decode | `decode/rtl/top/kv260_npu_generic_wrapper.v` | `decode/rtl/top/T_NPU_FPGA.sv` | `decode/rtl/top.files` |

`Versa_P_core` owns the prefill control, scratchpads, systolic array, and DMA datapath. `smolvlm2_decode` and `T_NPU_FPGA` compose the decode flow, GEMV, post-processing, DMA, and control blocks.

## AXI Contract

Both wrappers expose a 64-bit AXI4-Lite slave with 32-bit addresses, an interrupt, and four 128-bit AXI4 masters with 32-bit addresses and 4-bit IDs. In the archived KV260 block design the masters connected to PS HP0 through HP3. Prefill primarily used separate activation/weight reads and output writes; decode aggregates traffic across all four channels.

The physical base address and PS interconnect assignment belong to the missing block design, not to the RTL module itself. Software must use the addresses described by the deployed device tree/overlay.

## Registers

The register maps are defined directly in the stage controllers:

- Prefill: `prefill/rtl/ctrl/inst_ctrl.sv`. Descriptor/status groups start at `0x000` (MVIN A), `0x020` (MVIN W), `0x040` (metadata), `0x060` (GEMM), `0x080` (MVOUT), and `0x0a0` (attention QK). IRQ control starts at `0x100`; the common ABI block is at `0x0f00`.
- Decode: `decode/rtl/npu/inst_ctrl.sv`. Stream GEMV starts at `0x0300`, MLP at `0x0340`, attention at `0x0380`, debug operations at `0x0400`, KV scales at `0x04a0`, and the common ABI block at `0xff00` with a `0x0f00` alias.

These offsets are an RTL navigation aid, not a stable public driver ABI. The companion runtime revision is the authoritative caller for the archived design.

## Portable SRAM Models

`decode/rtl/utils/sram/sram_1024_dp_models.sv` replaces unavailable physical-IP simulation models while retaining the three module interfaces used by the decode RTL. The replacements implement active-low, masked, synchronous read-first dual-port memory. Same-address writes from both ports are unspecified. They are intended for syntax/elaboration and generic synthesis, not foundry timing or X-propagation equivalence.

## Build Status

The public tree lacks a complete project recreation flow and has not been rebuilt during this cleanup. No claim is made for current synthesis, placement, routing, timing, bitstream generation, or board behavior.
