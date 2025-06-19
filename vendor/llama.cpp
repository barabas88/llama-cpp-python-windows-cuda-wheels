# From the root of your new repo
git submodule add https://github.com/ggerganov/llama.cpp vendor/llama.cpp
git fetch --tags --depth=1 --recurse-submodules -C vendor/llama.cpp
git -C vendor/llama.cpp checkout b5709        # <-- first tag you want
git add .gitmodules vendor/llama.cpp
git commit -m "Pin llama.cpp submodule to b5709"
