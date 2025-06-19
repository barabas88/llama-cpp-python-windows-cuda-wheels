#!/usr/bin/env bash
set -euo pipefail

new_tag="${1:-}"
if [[ -z $new_tag ]]; then
  echo "Usage: $0 <llama.cpp tag>   e.g.  $0 b5711" >&2
  exit 1
fi

git fetch --tags -C vendor/llama.cpp
git -C vendor/llama.cpp checkout "$new_tag"
git add vendor/llama.cpp
git commit -m "Bump llama.cpp to $new_tag"
echo "✓ Submodule now at $new_tag – don't forget to push!"
