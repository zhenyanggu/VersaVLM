# Architecture

VersaVLM splits inference at the natural prefill/decode boundary and loads a stage-specific KV260 PL overlay. The PS remains responsible for llama.cpp graph execution, tokenizer and sampling, unsupported operators, memory allocation, and reconfiguration.

```text
Request -> llama.cpp/ggml -> NPU backend/runtime -> Linux driver
                                | AXI-Lite descriptors
                                | CMA physical buffers
                                v
                 +--------------+--------------+
                 |                             |
          prefill overlay               decode overlay
     tiled W8A8 GEMM/QK/PV        streaming W4A16/W8A16 GEMV
     Log8 attention materialize    RoPE/softmax/SiLU/KV quant
                 |                             |
                 +------------- DDR -----------+
```

## Prefill Stage

The prefill datapath uses a 32x32 INT8 systolic array and banked 256-bit scratchpads. It supports general W8A8 GEMM plus attention-specialized QK and PV modes. QK produces scaled distance and maximum metadata; the probability numerator is materialized as an 8-bit Log8 value. PV reloads this compact representation, decodes it, multiplies by INT8 V, accumulates a denominator, and normalizes rows.

## Decode Stage

Decode consumes one-token work with a streaming GEMV datapath and four DDR channels. The path supports W4A16/W8A16 projection and post-processing blocks for RoPE, online softmax, SiLU/SwiGLU, FP16 multiplication, and per-token/per-KV-head cache quantization. The RTL is specialized for SmolVLM2 geometry: hidden size 960, 15 query heads, 5 KV heads, and head dimension 64.

## Stage Transition

The host writes intermediate tensors and KV state to shared DDR, quiesces the current NPU, changes the FPGA Manager overlay, verifies the common control ABI, and resumes with the decode runtime path. The two overlays expose a common 64-bit AXI4-Lite control style and four 128-bit AXI4 masters, but their internal descriptors are stage-specific. Overlay switching and buffer ownership belong to the companion software repository.

## Host-PL Boundary

| Host/PS | Programmable logic |
| --- | --- |
| Model loading and ggml graph traversal | Regular tiled/streamed kernels |
| Tokenization and sampling | GEMM/GEMV execution |
| Unsupported-op fallback | Attention post-processing |
| CMA allocation and physical addressing | AXI DMA reads and writes |
| Descriptor creation and IRQ handling | Status, error, and profile counters |
| Overlay selection | Stage-specific datapath |

The repository contains RTL only. It does not contain the Linux image, driver package, models, bitstreams, or a complete Vivado project.
