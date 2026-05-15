#!/usr/bin/env bash
# Fresh-machine bootstrap. Idempotent — safe to re-run.
#
# Usage on a fresh Ubuntu install:
#   git clone git@github.com:lanteignel93/dot_files.git ~/dotfiles
#   bash ~/dotfiles/bootstrap.sh
#
# Then log out and back in to land in zsh.

set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
PRIVATE_REMOTE="${PRIVATE_REMOTE:-git@github.com:lanteignel93/dotfiles-private.git}"

log()  { printf '[bootstrap] %s\n' "$*"; }
warn() { printf '[bootstrap][WARN] %s\n' "$*" >&2; }
fail() { printf '[bootstrap][FAIL] %s\n' "$*" >&2; exit 1; }

[[ "$EUID" -ne 0 ]] || fail "Run as your user, not root."
[[ -d "$DOTFILES/.git" ]] || fail "$DOTFILES not found. Clone the repo there first."

# 1. APT packages
log "Installing apt packages..."
PKGS=(
  zsh tmux kitty neovim git curl wget gh
  fzf ripgrep fd-find bat
  build-essential
  fonts-jetbrains-mono
  awesome polybar nitrogen
  lazygit htop neofetch btop xclip
  jq stow
)
sudo apt-get update -y
sudo apt-get install -y "${PKGS[@]}" || warn "Some packages failed; review output"

# 2. oh-my-zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  log "Installing oh-my-zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  log "oh-my-zsh already present"
fi

# 3. Powerlevel10k
P10K="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
if [[ ! -d "$P10K" ]]; then
  log "Installing powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K"
else
  log "powerlevel10k already present"
fi

# 4. Private repo (best-effort, requires SSH key)
if [[ ! -d "$HOME/dotfiles-private/.git" ]]; then
  log "Cloning private repo..."
  git clone "$PRIVATE_REMOTE" "$HOME/dotfiles-private" || warn "Private repo clone failed (likely no SSH key yet)"
else
  log "private repo already present"
fi

# 5. Lay down symlinks
log "Running install.sh..."
LINK_SSH=1 bash "$DOTFILES/install.sh" || warn "install.sh reported conflicts; review above"

# 6. TPM (Tmux Plugin Manager) — the .tmux/ dir is now a symlink to the repo's .tmux/
#    The repo tracks TPM at .tmux/plugins/tpm. If absent (fresh clone of a future leaner repo), clone it.
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  log "Cloning TPM..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
  log "TPM already present"
fi

# 7. Nvim plugin install (headless, non-fatal if it errors)
log "Running nvim Lazy sync..."
nvim --headless "+Lazy! sync" +qa 2>&1 | tail -20 || warn "nvim Lazy sync had issues"

# 8. tmux plugin install (headless)
if [[ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]]; then
  log "Installing tmux plugins..."
  "$HOME/.tmux/plugins/tpm/bin/install_plugins" || warn "tmux plugin install had issues"
fi

# 9. Font cache
log "Refreshing font cache..."
fc-cache -f "$HOME/.fonts" 2>/dev/null || true

# 10. Default shell
if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$(which zsh)" ]]; then
  log "Changing default shell to zsh (will prompt for password)..."
  chsh -s "$(which zsh)" || warn "chsh failed; run manually"
else
  log "Default shell already zsh"
fi

# 11. systemd user timers (only if user wants daily-sync running)
log "Reloading systemd user units..."
systemctl --user daemon-reload || true
if systemctl --user list-unit-files daily-sync.timer >/dev/null 2>&1; then
  systemctl --user enable --now daily-sync.timer 2>&1 || warn "Could not enable daily-sync.timer"
fi

log ""
log "=========================================="
log "Bootstrap done. Manual follow-ups:"
log "  - 'gh auth login' if not signed in"
log "  - SSH keys: ~/.ssh/id_* (not tracked anywhere — transfer manually)"
log "  - 'git config --global user.name' / 'user.email' if not set"
log "  - 'p10k configure' if you want to tweak the prompt theme"
log "  - Log out and back in to land in zsh"
log "=========================================="
