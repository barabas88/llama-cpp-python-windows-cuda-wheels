<#
  Builds a single “fat” CUDA+CPU wheel of llama-cpp-python
  (architectures 75 / 86 / 89; CUDA 12.4)
#>

$ErrorActionPreference = 'Stop'

# -------- user-configurable pin -----------------------------------
$LLAMA_TAG   = 'b5711'                       # upstream tag to pin
$CUDA_ARCHES = '75;86;89'                    # Turing / Ampere / Ada
# ------------------------------------------------------------------

# ── 1) create & activate venv ──────────────────────────────────────
if (!(Test-Path .venv)) { py -3.12 -m venv .venv }
. .venv\Scripts\activate.ps1
pip install -U pip ninja cmake scikit-build-core build

# (sub-module already cloned by checkout)
git -C vendor/llama.cpp fetch --tags --depth 1
git -C vendor/llama.cpp checkout $LLAMA_TAG

# ── 2) environment for CMake / nvcc ───────────────────────────────
$env:CMAKE_ARGS = "-DGGML_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES=$CUDA_ARCHES -DLLAMA_CURL=OFF -DLLAVA_BUILD=OFF"
$env:CUDA_PATH  = "$env:ProgramFiles\NVIDIA GPU Computing Toolkit\CUDA\v12.4"
$env:Path       = "$env:CUDA_PATH\bin;$env:Path"

# ── 3) native build of llama.cpp ───────────────────────────────────
Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue
cmake -S vendor/llama.cpp -B build -G "NMake Makefiles" $env:CMAKE_ARGS -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release -j ([Environment]::ProcessorCount)

# ── 4) copy extra helper binary (optional but nice to have) ────────
New-Item -ItemType Directory -Path llama_cpp\lib -Force | Out-Null
Copy-Item build\bin\llama-mtmd-cli.exe llama_cpp\lib\ -Force

# ── 5) Python wheel build ─────────────────────────────────────────
python -m build -w --no-isolation
Write-Host "==== DONE!  Wheel is in dist\  ===="
