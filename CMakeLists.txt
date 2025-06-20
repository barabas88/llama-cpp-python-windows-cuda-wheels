cmake_minimum_required(VERSION 3.26)     # or whatever you like
project(llama_cpp_python_windows_cuda LANGUAGES C)  # no build targets –
# we built everything ourselves in build-wheel.ps1, the libraries
# already live inside the Python package directory.
