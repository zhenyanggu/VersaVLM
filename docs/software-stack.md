# Software Stack

The host stack is maintained separately at [`zhenyanggu/llama_cpp`](https://github.com/zhenyanggu/llama_cpp). Use the [`npu-dev`](https://github.com/zhenyanggu/llama_cpp/tree/npu-dev) branch; the competition-compatible revision is [`bf5e05be8ba6710c959e4a400c586ec00e0ae4ca`](https://github.com/zhenyanggu/llama_cpp/commit/bf5e05be8ba6710c959e4a400c586ec00e0ae4ca).

The repository is attached at `software/llama_cpp` as a shallow Git submodule. A recursive clone checks out the exact compatible revision:

```bash
git clone --recurse-submodules https://github.com/zhenyanggu/VersaVLM.git
```

For an existing VersaVLM clone:

```bash
git submodule update --init --recursive
git -C software/llama_cpp rev-parse HEAD
```

The second command should print `bf5e05be8ba6710c959e4a400c586ec00e0ae4ca`.

## Responsibilities

| Layer | Responsibility |
| --- | --- |
| llama.cpp/ggml | Model loading, graph traversal, tokenizer, sampling, server, CPU fallback |
| ggml NPU backend | Operator selection and prefill/decode dispatch |
| NPU runtime | Packing, descriptors, bank state, CMA buffers, profiles, overlay state |
| Linux driver | MMIO, CMA mapping, IRQ, and ioctl interface |
| VersaVLM RTL | AXI-controlled stage-specific acceleration |

Within the submodule, the KV260-specific integration is centered on the ggml NPU backend and `npuruntime/kv260/`; the exact layout at the pinned revision is authoritative.

The software and hardware communicate through physical DMA buffers, AXI4-Lite descriptors/status, interrupts, and a small common identification/capability block. Prefill produces model state in DDR; the host switches overlays before decode consumes that state and appends the KV cache.

The host repository is linked, not vendored or relicensed. Its upstream llama.cpp portions use the MIT License; inspect the submodule at the pinned revision for all applicable notices and build/deployment instructions.

## Version Boundary

Descriptor layouts and buffer conventions evolved with the RTL. The submodule gitlink, rather than current `npu-dev` HEAD, defines compatibility for this artifact. A recursive clone still does not supply model files, the Linux image, device tree, overlays, or board setup.
