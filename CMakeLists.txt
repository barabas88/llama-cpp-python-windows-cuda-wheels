cmake_minimum_required(VERSION 3.24)
project(llama_cpp_python_windows_cuda LANGUAGES C CXX CUDA)

# Pull in upstream llama.cpp build
add_subdirectory(vendor/llama.cpp)

# ---------- install section ----------
# All runtime DLLs / EXEs into the Python package dir
set(PKG_ROOT ${CMAKE_INSTALL_PREFIX}/llama_cpp/lib)

install(TARGETS
        llama              # llama.dll
        ggml-cuda          # ggml-cuda.dll
        mtmd               # mtmd.dll
        llama-server       # cli exe, optional
        RUNTIME DESTINATION ${PKG_ROOT})

# If you staged extra EXEs manually:
install(FILES ${CMAKE_BINARY_DIR}/bin/llama-mtmd-cli.exe
        DESTINATION ${PKG_ROOT})
