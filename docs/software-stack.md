# Software Stack

The host stack is maintained separately at [`zhenyanggu/llama_cpp`](https://github.com/zhenyanggu/llama_cpp). Use the [`npu-dev`](https://github.com/zhenyanggu/llama_cpp/tree/npu-dev) branch; the competition-compatible revision is [`bf5e05be8ba6710c959e4a400c586ec00e0ae4ca`](https://github.com/zhenyanggu/llama_cpp/commit/bf5e05be8ba6710c959e4a400c586ec00e0ae4ca).

## Responsibilities

| Layer | Responsibility |
| --- | --- |
| llama.cpp/ggml | Model loading, graph traversal, tokenizer, sampling, server, CPU fallback |
| ggml NPU backend | Operator selection and prefill/decode dispatch |
| NPU runtime | Packing, descriptors, bank state, CMA buffers, profiles, overlay state |
| Linux driver | MMIO, CMA mapping, IRQ, and ioctl interface |
| VersaVLM RTL | AXI-controlled stage-specific acceleration |

The software and hardware communicate through physical DMA buffers, AXI4-Lite descriptors/status, interrupts, and a small common identification/capability block. Prefill produces model state in DDR; the host switches overlays before decode consumes that state and appends the KV cache.

The host repository is not vendored or modified here. Its upstream llama.cpp portions use the MIT License; inspect that repository at the pinned revision for all applicable notices and build/deployment instructions.

## Version Boundary

Descriptor layouts and buffer conventions evolved with the RTL. Do not assume current `npu-dev` HEAD remains compatible with this artifact: use the pinned commit when studying the competition configuration. A Git commit pin does not supply the missing model files, Linux image, device tree, overlays, or board setup.
