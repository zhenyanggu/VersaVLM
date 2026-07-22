# VersaVLM

[中文](README.zh-CN.md) | [Architecture](docs/architecture.md) | [Hardware](docs/hardware.md) | [Software stack](docs/software-stack.md) | [Reported results](docs/results.md)

VersaVLM is a research FPGA artifact for accelerating SmolVLM2-family inference on the AMD/Xilinx Kria KV260 with separate prefill and autoregressive-decode overlays.

> **Research prototype:** this repository publishes the RTL sources used to describe the design. It does not provide a newly validated one-command build, and the current public tree has not been shown to reproduce the competition bitstreams bit-for-bit.

## Architecture

```text
              KV260 Processing System (Linux + llama.cpp/ggml)
        tokenizer / graph / fallback / sampling / overlay control
                         | AXI-Lite + CMA buffers
                         v
        +----------------+----------------+
        |                                 |
 +------v-------+                  +------v-------+
 | Prefill      |  overlay switch | Decode       |
 | 32x32 INT8 SA| ---------------->| stream GEMV  |
 | QK + Log8 PV |  shared DDR/KV   | RoPE/softmax |
 +------+-------+                  +------+-------+
        | four 128-bit AXI masters        |
        +----------------+----------------+
                         v
                        DDR
```

The host executes irregular control and unsupported operators. The prefill overlay targets reuse-heavy matrix operations with an INT8 systolic array and Log8 attention path. The decode overlay targets bandwidth-bound single-token execution with W4A16/W8A16 GEMV, RoPE, online softmax, SiLU, and quantized KV-cache writes. See [the architecture notes](docs/architecture.md).

## Repository Layout

| Path | Contents |
| --- | --- |
| [`prefill/`](prefill/) | Prefill RTL, `Versa_P` top, KV260 IP wrapper, and core filelist. |
| [`decode/`](decode/) | Decode RTL, `T_NPU_FPGA` top, stream decode pipeline, utilities, and filelists. |
| [`software/llama_cpp`](software/llama_cpp) | Companion host stack as a pinned Git submodule. |
| [`docs/`](docs/) | Architecture, hardware contract, companion software, and reported results. |

The stages are documented independently in [prefill/README.md](prefill/README.md) and [decode/README.md](decode/README.md).

## Hardware Target

- Board: AMD/Xilinx Kria KV260 Vision AI Starter Kit
- Device: `xck26-sfvc784-2LV-c`
- Board part: `xilinx.com:kv260_som:part0:1.4`
- Tool version used for the archived competition project: Vivado 2025.1
- Reported clocks: approximately 190 MHz prefill and 200 MHz decode
- Control: 64-bit AXI4-Lite; memory: four 128-bit AXI4 master interfaces

Generated Vivado projects, constraints, block-design scripts, IP packaging metadata, and implementation outputs are not complete in this repository. The filelists are useful source inventories, not a supported build system. No synthesis, implementation, timing closure, or board regression was run during this open-source cleanup.

## Software Boundary

Host integration lives in the separate [`zhenyanggu/llama_cpp`](https://github.com/zhenyanggu/llama_cpp/tree/npu-dev) repository on branch `npu-dev`. It is registered at [`software/llama_cpp`](software/llama_cpp) as a shallow Git submodule pinned to the competition-compatible revision [`bf5e05be8`](https://github.com/zhenyanggu/llama_cpp/commit/bf5e05be8ba6710c959e4a400c586ec00e0ae4ca).

Clone both repositories together with:

```bash
git clone --recurse-submodules https://github.com/zhenyanggu/VersaVLM.git
```

For an existing clone, initialize the software stack with `git submodule update --init --recursive`. The submodule supplies the llama.cpp/ggml NPU backend, runtime, Linux driver, buffer management, descriptor construction, and overlay switching. See [docs/software-stack.md](docs/software-stack.md) for component locations, the hardware/software boundary, and license notes.

## Reported Results

The archived AICAS submission reported the following measurements:

| Metric | Reported value |
| --- | ---: |
| Evaluation accuracy | 13/30 (0.433333) |
| Prefill throughput | 30.555 tokens/s |
| Decode throughput | 12.447 tokens/s |
| Energy efficiency | 2.280 tokens/J |
| TTFT fit | 2.195 ms/character slope, 10638.027 ms intercept |

These are historical submission results, not measurements reproduced during this repository cleanup. Workload details and additional context are in [docs/results.md](docs/results.md).

## Model and Data

The design targets SmolVLM2-family GGUF text and multimodal-projector models, with decode RTL specialized around hidden size 960, 15 query heads, 5 KV heads, and head dimension 64. Model weights remain subject to their upstream terms and are not included.

This repository also excludes Linux images, bitstreams, XSA files, overlay packages, competition videos, raw benchmark logs, and generated Vivado state.

## Known Limitations

- The design is model- and KV260-specific; portability to other models or FPGA boards is not claimed.
- The two overlays require host-managed reconfiguration at the prefill/decode boundary.
- Portable RAM models replace unavailable physical-memory simulation models and are not cycle-accurate foundry models.
- No public end-to-end build recipe or supported deployment image is provided.
- This is a read-only research artifact without a feature-support commitment.

## License and Citation

Original work is licensed under [Apache License 2.0](LICENSE), Copyright 2026 FuxionLab. Third-party BSD-3-Clause and SHL-0.51 components retain their source notices; see [NOTICE](NOTICE). The companion llama.cpp repository is separately licensed under MIT.

Citation metadata is available in [CITATION.cff](CITATION.cff). Please cite the repository version or commit used in your work.
