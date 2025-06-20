$ErrorActionPreference = 'Stop'

# ---------------- env from build.env ----------------
(Get-Content build.env) -match '=' | ForEach-Object {
  $name,$val = $_ -split '=',2
  Set-Variable $name $val
}

# ---------------- Python venv ----------------
if (!(Test-Path .venv)) { py -3.12 -m venv .venv }
. .venv\Scripts\activate.ps1

# **SAFE package install – no self-upgrade race**
python -m pip install ninja cmake scikit-build-core build

# ---------------- git / submodule ----------------
git submodule update --init --depth 1 --recursive
git -C vendor/llama.cpp fetch --tags --depth 1
git -C vendor/llama.cpp checkout $LLAMA_TAG

# ---------------- native build -------------------
$env:CMAKE_ARGS="-DGGML_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES=$CUDA_ARCHES -DLLAMA_CURL=OFF -DLLAVA_BUILD=OFF"
$env:CUDA_PATH="$env:ProgramFiles\NVIDIA GPU Computing Toolkit\CUDA\v12.8"
$env:Path="$env:CUDA_PATH\bin;$env:Path"

Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue
cmake -S vendor/llama.cpp -B build -G "NMake Makefiles" $env:CMAKE_ARGS -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release -j ([Environment]::ProcessorCount)

# ---------------- wheel stage ---------------------
New-Item -ItemType Directory -Path llama_cpp\lib -Force | Out-Null
Copy-Item build\bin\llama-mtmd-cli.exe llama_cpp\lib\ -Force

python -m build -w --no-isolation
Write-Host "==== DONE, wheel in dist\ ===="
