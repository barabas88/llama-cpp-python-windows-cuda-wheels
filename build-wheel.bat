@echo off
REM ------------------------------------------------------------
REM Build a CUDA wheel for abetlen/llama-cpp-python on Windows
REM Requires: VS 2022, CUDA Toolkit 12.8, Git
REM ------------------------------------------------------------
setlocal enabledelayedexpansion

REM -- read env
for /f "usebackq tokens=1,2 delims==" %%A in (`type build.env`) do set %%A=%%B

REM -- toolchain
call "%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"

REM -- Python venv
if not exist .venv (
    py -3.12 -m venv .venv
)
call .venv\Scripts\activate.bat
python -m pip install -U pip ninja cmake scikit-build-core build

REM -- fetch / pin submodule
git submodule update --init --depth 1 --recursive
git -C vendor\llama.cpp fetch --tags --depth 1
git -C vendor\llama.cpp checkout %LLAMA_TAG%

REM -- configuration knobs
set CMAKE_ARGS=-DGGML_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES=%CUDA_ARCHES% -DLLAMA_CURL=OFF -DLLAVA_BUILD=OFF
set "CUDA_PATH=%ProgramFiles%\NVIDIA GPU Computing Toolkit\CUDA\v12.8"
set "PATH=%CUDA_PATH%\bin;%PATH%"

REM -- native compile
rmdir /s /q build 2>nul
cmake -S vendor/llama.cpp -B build -G "NMake Makefiles" %CMAKE_ARGS% -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release -j %NUMBER_OF_PROCESSORS%

REM -- copy MTMD CLI (multimodal)
mkdir llama_cpp\lib 2>nul
copy /y build\bin\llama-mtmd-cli.exe llama_cpp\lib\ >nul

REM -- build wheel
python -m build -w --no-isolation

echo ==== DONE, wheel in dist\ ====
