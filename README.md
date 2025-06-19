# 🦙 llama-cpp-python-windows-cuda-wheels (for Windows x64 + CUDA 12.8)

Pre-built **Python wheels** of [`abetlen/llama-cpp-python`](https://github.com/abetlen/llama-cpp-python)  
with:

* **CUDA** kernels for Turing ↔ Ada (`sm_75 86 89`)
* **YARN + Rope-scaling** (`b57xx` tags upstream)
* **MTMD** multimodal CLI (`llama-mtmd-cli.exe`) placed in `llama_cpp/lib`
* Curl, LLava/Lava components _disabled_ → leaner wheel, no extra DLL hell

> Need a newer tag?  
> `pwsh scripts\bump-llama.ps1 b5711 && git push`

| hardware | toolkit | Python | wheel tag |
|----------|--------|--------|-----------|
| RTX 20/30/40 series | CUDA 12.8 | 3.9 – 3.12 | `-cu128-…-sm75_86_89.whl` |

---

## Quick start

```PowerShell
# One-liner install (user site)
pip install https://github.com/<YOU>/llama-cpp-python-windows-cuda-wheels/releases/download/v0.1/llama_cpp-2.2.2+cu128-cp312-cp312-win_amd64.whl
After that:

from llama_cpp import Llama
llm = Llama(model_path="…/zephyr-7b-yarn.gguf", n_gpu_layers=-1)
print(llm("Hello, world!", max_tokens=12))
Building yourself (Windows 11, VS 2022 Community + CUDA 12.8)

REM 0. prerequisites:  Visual Studio “Desktop C++”  +  CUDA 12.8
REM 1. open “x64 Native Tools Command Prompt for VS 2022”
REM 2. clone + run:
git clone --recursive https://github.com/<YOU>/llama-cpp-wheels
cd llama-cpp-wheels
build-wheel.bat
A wheel appears in dist\.
All heavy knobs live in build.env; edit once, re-build everywhere.

Repo layout
vendor/llama.cpp – upstream code (pinned tag in build.env)

CI – builds wheels on every push & publishes on GitHub Releases

Watcher bot – nightly PR when new b57xx tag lands upstream