# VersaVLM

[English](README.md) | [架构](docs/architecture.md) | [硬件](docs/hardware.md) | [软件栈](docs/software-stack.md) | [已有结果](docs/results.md)

VersaVLM 是面向 AMD/Xilinx Kria KV260 的研究型 FPGA VLM 推理加速 artifact，针对 SmolVLM2 系列模型分别使用 prefill 与自回归 decode 两个 overlay。

> **研究原型说明：** 本仓库公开用于描述设计的 RTL 源码，但暂不提供经过重新验证的一键构建流程，也不声明当前公开目录能够逐比特复现比赛 bitstream。

## 架构

```text
                KV260 PS（Linux + llama.cpp/ggml）
        tokenizer / 图调度 / CPU 回退 / sampling / overlay 控制
                         | AXI-Lite + CMA buffer
                         v
        +----------------+----------------+
        |                                 |
 +------v-------+                  +------v-------+
 | Prefill      |  overlay 切换   | Decode       |
 | 32x32 INT8 SA| ---------------->| 流式 GEMV    |
 | QK + Log8 PV |  共享 DDR/KV    | RoPE/softmax |
 +------+-------+                  +------+-------+
        | 四路 128-bit AXI master        |
        +----------------+----------------+
                         v
                        DDR
```

Host 负责不规则控制和未下放算子。Prefill overlay 以 INT8 systolic array 和 Log8 attention 路径处理高复用矩阵运算；decode overlay 以 W4A16/W8A16 GEMV、RoPE、online softmax、SiLU 和量化 KV cache 写回处理带宽受限的单 token 推理。详见 [架构文档](docs/architecture.md)。

## 目录

| 路径 | 内容 |
| --- | --- |
| [`prefill/`](prefill/) | Prefill RTL、`Versa_P` 顶层、KV260 IP wrapper 和 filelist。 |
| [`decode/`](decode/) | Decode RTL、`T_NPU_FPGA` 顶层、流式 decode pipeline、工具模块和 filelist。 |
| [`software/llama_cpp`](software/llama_cpp) | 以固定 Git submodule 引用的配套 Host 软件栈。 |
| [`docs/`](docs/) | 架构、硬件接口、配套软件和已有结果。 |

阶段说明见 [prefill/README.md](prefill/README.md) 与 [decode/README.md](decode/README.md)。

## 硬件与工具

- 板卡：AMD/Xilinx Kria KV260 Vision AI Starter Kit
- 器件：`xck26-sfvc784-2LV-c`
- Board part：`xilinx.com:kv260_som:part0:1.4`
- 比赛归档工程使用 Vivado 2025.1
- 已报告时钟：prefill 约 190 MHz，decode 约 200 MHz
- 控制接口：64-bit AXI4-Lite；存储接口：四路 128-bit AXI4 master

本仓库未完整提供生成后的 Vivado 工程、约束、Block Design 脚本、IP 打包元数据或实现产物。filelist 是源码清单，不是受支持的构建系统。本次整理没有运行综合、实现、时序收敛或板端回归。

## 软件边界

Host 集成位于独立仓库 [`zhenyanggu/llama_cpp`](https://github.com/zhenyanggu/llama_cpp/tree/npu-dev) 的 `npu-dev` 分支，并作为浅层 Git submodule 挂在 [`software/llama_cpp`](software/llama_cpp)。子模块固定到比赛兼容版本 [`bf5e05be8`](https://github.com/zhenyanggu/llama_cpp/commit/bf5e05be8ba6710c959e4a400c586ec00e0ae4ca)。

同时获取硬件与软件：

```bash
git clone --recurse-submodules https://github.com/zhenyanggu/VersaVLM.git
```

已经克隆主仓时，执行 `git submodule update --init --recursive`。该软件栈包含 llama.cpp/ggml NPU backend、runtime、Linux driver、buffer 管理、descriptor 构造和 overlay 切换逻辑；模块位置和软硬件边界见 [软件栈文档](docs/software-stack.md)。

## 已报告结果

| 指标 | 已报告值 |
| --- | ---: |
| Accuracy | 13/30（0.433333） |
| Prefill throughput | 30.555 tokens/s |
| Decode throughput | 12.447 tokens/s |
| Energy efficiency | 2.280 tokens/J |
| TTFT 拟合 | 斜率 2.195 ms/字符，截距 10638.027 ms |

以上是已有 AICAS 提交结果，并未在本次开源整理中重新验证。详见 [results.md](docs/results.md)。

## 模型、限制与许可证

设计面向 SmolVLM2 系列 GGUF text/mmproj 模型；decode RTL 针对 hidden size 960、15 个 Q head、5 个 KV head 和 head dimension 64 做了特化。模型权重遵循上游条款，本仓库不包含模型、Linux 镜像、bitstream、XSA、overlay 包、比赛视频、原始日志或 Vivado 生成目录。

该设计专用于 KV260 和特定模型，不承诺其他平台适配；两个阶段需要 host 管理 overlay 切换；替换后的通用 RAM 模型不是 foundry 宏的周期精确模型；项目定位为只读研究 artifact，不承诺功能支持。

原创部分采用 [Apache-2.0](LICENSE)，Copyright 2026 FuxionLab。BSD-3-Clause 与 SHL-0.51 第三方代码保留源文件声明，详见 [NOTICE](NOTICE)。引用信息见 [CITATION.cff](CITATION.cff)。
