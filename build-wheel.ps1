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
$LLAMA_TAG = $env:LLAMA_TAG ?? 'b5709'      # default if not set
git -C vendor/llama.cpp checkout $LLAMA_TAG

# ────────────────────────────── 3.  Configure CUDA env ──────────────
$env:CUDA_PATH = "$env:ProgramFiles\NVIDIA GPU Computing Toolkit\CUDA\v12.4"
$env:Path      = "$env:CUDA_PATH\bin;$env:Path"

# ─ 4. Generate build tree ─
Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue

$cmakeArgs = @(
    '-DGGML_CUDA=ON',
    '-DCMAKE_CUDA_ARCHITECTURES=75;86;89',
    '-DLLAMA_CURL=OFF',
    '-DLLAVA_BUILD=OFF',
    '-DCMAKE_BUILD_TYPE=Release'
)

cmake -S vendor/llama.cpp -B build -G Ninja @cmakeArgs   # ← changed

# ─ 5. Compile ─
cmake --build build --config Release --parallel           # ← changed

# ────────────────────────────── 6.  Stage extra exe ─────────────────
New-Item -ItemType Directory -Path llama_cpp\lib -Force | Out-Null
Copy-Item build\bin\llama-mtmd-cli.exe llama_cpp\lib\ -Force

# ────────────────────────────── 7.  Build wheel ─────────────────────
python -m build -w --no-isolation
Write-Host '==== DONE, wheel in dist\ ===='
