# Companion Software

`llama_cpp/` is a Git submodule pointing to the KV260 host stack at the competition-compatible commit `bf5e05be8ba6710c959e4a400c586ec00e0ae4ca`.

Initialize it after cloning VersaVLM with:

```bash
git submodule update --init --recursive
```

The submodule contains the llama.cpp/ggml NPU backend, KV260 runtime and Linux driver, buffer/descriptor handling, and overlay control. See [`../docs/software-stack.md`](../docs/software-stack.md) for the component boundary. The software repository keeps its own license and third-party notices; adding it as a submodule does not place it under VersaVLM's Apache-2.0 license.
