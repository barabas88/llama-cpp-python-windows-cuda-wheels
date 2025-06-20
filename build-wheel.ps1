# build-wheel.ps1
$ErrorActionPreference = 'Stop'

# ────────────────────────────── 0.  Load per-build env (optional) ───
if (Test-Path build.env) {
    (Get-Content build.env) -match '=' | ForEach-Object {
        $name, $val = $_ -split '=', 2
        Set-Variable $name $val
    }
}

# ────────────────────────────── 1.  Python venv & deps ──────────────
if (-not (Test-Path .venv)) { py -3.12 -m venv .venv }
. .\.venv\Scripts\Activate.ps1
python -m pip install -U pip ninja cmake scikit-build-core build

# ────────────────────────────── 2.  Update/checkout submodule ───────
git submodule update --init --depth 1 --recursive
git -C vendor/llama.cpp fetch --tags --depth 1
$LLAMA_TAG = $env:LLAMA_TAG ?? 'b5709'
git -C vendor/llama.cpp checkout $LLAMA_TAG
if (Test-Path vendor/llama.cpp/pyproject.toml) {
    Move-Item vendor/llama.cpp/pyproject.toml vendor/llama.cpp/pyproject.toml.bak
}

# ────────────────────────────── 3.  Configure CUDA env ──────────────
$env:CUDA_PATH = "$env:ProgramFiles\NVIDIA GPU Computing Toolkit\CUDA\v12.4"
$env:Path      = "$env:CUDA_PATH\bin;$env:Path"

# ────────────────────────────── 4.  Build wheel ─────────────────────
$env:CMAKE_ARGS = @(
    "-DGGML_CUDA=ON",
    "-DCMAKE_CUDA_ARCHITECTURES=75;86;89",
    "-DLLAMA_CURL=OFF",
    "-DLLAVA_BUILD=OFF"
) -join ' '

Remove-Item -Recurse -Force build,dist -ErrorAction SilentlyContinue
python -m build -w --no-isolation
Write-Host '==== DONE, wheel in dist\ ===='