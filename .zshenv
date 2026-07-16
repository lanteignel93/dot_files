# Read by every zsh, before .zshrc, including non-interactive shells.
# Environment variables only — interactive config stays in .zshrc.

# CMake >=3.17 honors this env var: every configure emits
# compile_commands.json so clangd gets real flags in every checkout.
export CMAKE_EXPORT_COMPILE_COMMANDS=ON

# rustup: puts ~/.cargo/bin on PATH (non-interactive shells need it too)
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
