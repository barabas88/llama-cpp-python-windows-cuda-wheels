Param(
  [Parameter(Mandatory=$true)][string]$Tag
)
git fetch --tags -C vendor/llama.cpp
git -C vendor/llama.cpp checkout $Tag
git add vendor/llama.cpp
git commit -m "Bump llama.cpp to $Tag"
Write-Host "✓ Submodule now at $Tag – don't forget git push"
