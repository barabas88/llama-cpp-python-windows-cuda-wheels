$ErrorActionPreference = 'Stop'

# ── 0. matrix -------------------------------------------------------------
(Get-Content build.env) -match '=' | ForEach-Object {
    $n,$v = $_ -split '=',2; Set-Variable $n $v
}

# ── 1. venv + helpers -----------------------------------------------------
if (-not (Test-Path .venv)) { py -3.12 -m venv .venv }
. .venv\Scripts\Activate.ps1
python -m pip install -U pip ninja cmake scikit-build-core build

# ── 2. bring the sub-module to life --------------------------------------
git submodule update --init --recursive --depth 1          # <-- *NEW*
git -C vendor/llama.cpp fetch --tags --depth 1
git -C vendor/llama.cpp checkout $LLAMA_TAG                # b57xx

# ── 3. build native libs --------------------------------------------------
$env:CMAKE_ARGS = "-DGGML_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES=$CUDA_ARCHES -DLLAMA_CURL=OFF -DLLAVA_BUILD=OFF"
$env:CUDA_PATH = "$env:ProgramFiles\NVIDIA GPU Computing Toolkit\CUDA\v12.4"
$env:Path      = "$env:CUDA_PATH\bin;$env:Path"

Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue
cmake -S vendor/llama.cpp -B build -G "NMake Makefiles" $env:CMAKE_ARGS -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release --parallel ([Environment]::ProcessorCount)

# ── 4. copy extra CLI -----------------------------------------------------
New-Item -ItemType Directory -Path llama_cpp\lib -Force | Out-Null
Copy-Item build\bin\llama-mtmd-cli.exe llama_cpp\lib\ -Force

# ── 5. build the wheel ----------------------------------------------------
python -m build -w --no-isolation
Write-Host "==== DONE — wheel is in dist/ ===="
