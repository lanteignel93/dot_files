#!/usr/bin/env bash
# Fresh-machine bootstrap. Idempotent — safe to re-run.
#
# Usage on a fresh Ubuntu install:
#   git clone git@github.com:lanteignel93/dot_files.git ~/dotfiles
#   bash ~/dotfiles/bootstrap.sh
#
# Then log out and back in to land in zsh.
#
# Division of labour:
#   bootstrap.sh  installs SOFTWARE (packages, toolchains, plugins) — run once
#   install.sh    links CONFIG from this repo into $HOME — run any time
# bootstrap.sh calls install.sh at step 6.
#
# Flags:
#   SKIP_APT=1     skip the apt section (already provisioned)
#   SKIP_HEAVY=1   skip texlive, virtualbox and other large optional installs
#   SKIP_LANG=1    skip rust / node / uv toolchains
#   NVIM_VERSION=  neovim release tag to converge on (default below, e.g. v0.12.4).
#                  Re-running bootstrap after bumping it upgrades that box.

set -uo pipefail        # NOT -e: one failed optional install must not abort the run

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
PRIVATE_REMOTE="${PRIVATE_REMOTE:-git@github.com:lanteignel93/private_configs.git}"
PRIVATE_DIR="${PRIVATE_DIR:-$HOME/dotfiles-private}"
SKIP_APT="${SKIP_APT:-0}"
SKIP_HEAVY="${SKIP_HEAVY:-1}"     # heavy extras are opt-IN
SKIP_LANG="${SKIP_LANG:-0}"

log()  { printf '[bootstrap] %s\n' "$*"; }
warn() { printf '[bootstrap][WARN] %s\n' "$*" >&2; }
fail() { printf '[bootstrap][FAIL] %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

FAILURES=()
note_fail() { FAILURES+=("$1"); warn "$1"; }

[[ "$EUID" -ne 0 ]] || fail "Run as your user, not root."
[[ -d "$DOTFILES/.git" ]] || fail "$DOTFILES not found. Clone the repo there first."

mkdir -p "$HOME/.local/bin"

# =============================================================================
# 0. Distro detection
#
# Ubuntu at home, Fedora at work. Package NAMES differ enough that a shared
# list is not possible — python3-dev vs python3-devel, libssl-dev vs
# openssl-devel, build-essential vs the @development-tools group. So each
# distro gets its own explicit list rather than a lossy translation table.
# =============================================================================
. /etc/os-release 2>/dev/null || true
DISTRO="${ID:-unknown}"
case "$DISTRO" in
  ubuntu|debian|pop|linuxmint) FAMILY=debian ;;
  fedora|rhel|centos|rocky|almalinux) FAMILY=fedora ;;
  *) FAMILY=unknown ;;
esac
log "Detected: ${PRETTY_NAME:-$DISTRO}  (family: $FAMILY)"

if [[ "$FAMILY" == "debian" ]]; then
  PKG_UPDATE=(sudo apt-get update -y)
  PKG_INSTALL=(sudo apt-get install -y)
  CORE=(zsh tmux git curl wget gh build-essential pkg-config)
  CLI_QOL=(fzf ripgrep fd-find bat exa zoxide duf tree jq stow
           htop btop neofetch cmatrix xclip xsel xdotool
           unzip p7zip-full net-tools dnsutils)
  CPP=(cmake ninja-build ccache clang clangd clang-format clang-tidy lldb
       gdb valgrind libssl-dev zlib1g-dev libboost-all-dev)
  PYTHON=(python3-pip python3-venv python3-dev ipython3)
  STORAGE=(smartmontools nvme-cli exfatprogs exfat-fuse
           sshfs fuse3 cifs-utils rclone)
  DESKTOP=(awesome polybar nitrogen arandr flameshot remmina
           fonts-jetbrains-mono fonts-firacode ffmpeg pandoc)
  HEAVY=(texlive-latex-extra virtualbox)

elif [[ "$FAMILY" == "fedora" ]]; then
  PKG_UPDATE=(sudo dnf -y makecache)
  PKG_INSTALL=(sudo dnf install -y --skip-unavailable)
  # gh and rclone are in the standard Fedora repos; no extra COPR needed.
  CORE=(zsh tmux git curl wget gh gcc gcc-c++ make pkgconf-pkg-config)
  CLI_QOL=(fzf ripgrep fd-find bat eza zoxide duf tree jq stow
           htop btop neofetch cmatrix xclip xsel xdotool
           unzip p7zip bind-utils net-tools)
  CPP=(cmake ninja-build ccache clang clang-tools-extra lldb
       gdb valgrind openssl-devel zlib-devel boost-devel)
  PYTHON=(python3-pip python3-devel python3-ipython)
  STORAGE=(smartmontools nvme-cli exfatprogs
           fuse-sshfs fuse3 cifs-utils rclone)
  DESKTOP=(awesome polybar nitrogen arandr flameshot remmina
           jetbrains-mono-fonts fira-code-fonts ffmpeg-free pandoc)
  HEAVY=(texlive-scheme-medium VirtualBox)

else
  warn "Unrecognised distro '$DISTRO' — skipping package installation."
  warn "Install the equivalents by hand, then re-run with SKIP_APT=1."
  SKIP_APT=1
fi

# =============================================================================
# 1. System packages
# =============================================================================
if [[ "$SKIP_APT" == "0" ]]; then
  log "Refreshing package metadata..."
  "${PKG_UPDATE[@]}" >/dev/null 2>&1 || note_fail "package metadata refresh"

  for group in CORE CLI_QOL CPP PYTHON STORAGE DESKTOP; do
    declare -n pkgs="$group"
    log "Installing ${group}: ${#pkgs[@]} packages..."
    # A batch install is far faster, but on apt one unknown name aborts the
    # whole transaction. Try the batch; only fall back to per-package (slow,
    # but pinpoints the culprit) if it fails.
    if ! "${PKG_INSTALL[@]}" "${pkgs[@]}" >/dev/null 2>&1; then
      warn "$group batch failed — retrying individually to isolate"
      for p in "${pkgs[@]}"; do
        "${PKG_INSTALL[@]}" "$p" >/dev/null 2>&1 || note_fail "pkg: $p"
      done
    fi
  done

  if [[ "$SKIP_HEAVY" == "0" ]]; then
    log "Installing HEAVY extras..."
    "${PKG_INSTALL[@]}" "${HEAVY[@]}" >/dev/null 2>&1 || note_fail "heavy extras"
  else
    log "Skipping heavy extras (texlive, virtualbox) — SKIP_HEAVY=0 to include"
  fi

  # Debian renames two binaries that everything else calls bat and fd. The
  # .zshrc aliases already handle it, but scripts and muscle memory do not.
  [[ -x /usr/bin/batcat ]] && ln -sf /usr/bin/batcat "$HOME/.local/bin/bat"
  [[ -x /usr/bin/fdfind ]] && ln -sf /usr/bin/fdfind "$HOME/.local/bin/fd"
else
  log "SKIP_APT=1 — skipping package installation"
fi

# =============================================================================
# 1b. neovim and kitty — from upstream, NOT from the package manager
#
# Both are deliberately excluded from the package lists above:
#
#   neovim — Ubuntu 22.04 ships 0.6. The nvim config uses lazy.nvim, which
#            needs 0.9+, so the distro package produces an editor that errors
#            on startup. Installed to /usr/local so it matches the hardcoded
#            `alias vim="/usr/local/bin/nvim"` in .zshrc.
#   kitty  — the distro build lags and does not ship `kitten`, which
#            ~/.local/bin/kitten and the ssh helper rely on.
# =============================================================================
# Layout mirrors this machine exactly:
#   /opt/nvim/nvim/          extracted release
#   /usr/local/bin/nvim ->   /opt/nvim/nvim/bin/nvim
# The symlink is what makes the hardcoded `alias vim="/usr/local/bin/nvim"`
# in .zshrc resolve. (.zshrc also puts /opt/nvim/bin on PATH; that directory is
# empty and does nothing — harmless, kept only so the two boxes stay identical.)
#
# NVIM_VERSION pins the release tag and is the single knob that upgrades the
# whole fleet: bump it here, re-run bootstrap on each box. 'stable' and
# 'nightly' also work (they are just floating tags upstream) but a pinned
# vX.Y.Z is preferred, so every machine lands on the same build.
#
# This block UPGRADES as well as installs. It used to be `if ! have nvim`,
# which meant a box that already had any nvim was skipped forever — that is how
# the fleet ended up spread across year-old nightlies (0.12.0-dev-857 here,
# 0.12.0-dev-874 on HTAA) while this script reported "already present".
NVIM_VERSION="${NVIM_VERSION:-${NVIM_CHANNEL:-v0.12.4}}"
NVIM_PREFIX=/opt/nvim/nvim

# True when nvim is missing, or older than $NVIM_VERSION. Never downgrades.
# A -dev build of the target counts as older: prereleases sort before release.
nvim_outdated() {
  have nvim || return 0
  local want cur base first
  want="${NVIM_VERSION#v}"
  case "$want" in stable|nightly) return 0 ;; esac   # floating tags: always refresh
  cur=$(nvim --version 2>/dev/null | head -1 | sed -E 's/^NVIM v?//')
  [[ -z "$cur" ]] && return 0
  [[ "$cur" == "$want" ]] && return 1                # already exactly right
  base="${cur%%-*}"                                  # 0.12.0-dev-857+g46 -> 0.12.0
  [[ "$base" == "$want" ]] && return 0               # x.y.z-dev is older than x.y.z
  first=$(printf '%s\n%s\n' "$base" "$want" | sort -V | head -1)
  [[ "$first" == "$base" ]]                          # current older -> upgrade
}

if nvim_outdated; then
  if have nvim; then
    log "Upgrading neovim: $(nvim --version | head -1) -> $NVIM_VERSION"
  else
    log "Installing neovim $NVIM_VERSION..."
  fi
  tmp=$(mktemp -d)
  # Upstream renamed the asset to nvim-linux-x86_64 in 2024; older tags use
  # nvim-linux64, so try both rather than pinning to one era.
  for asset in nvim-linux-x86_64 nvim-linux64; do
    if curl -sSLf "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${asset}.tar.gz" \
         -o "$tmp/nvim.tar.gz" 2>/dev/null; then
      tar -xzf "$tmp/nvim.tar.gz" -C "$tmp" 2>/dev/null || continue
      d=$(find "$tmp" -maxdepth 1 -type d -name 'nvim-linux*' | head -1)
      [[ -n "$d" && -x "$d/bin/nvim" ]] || continue
      # Run the downloaded binary BEFORE it replaces a working editor. A bad
      # asset (wrong arch, truncated download) would otherwise leave the box
      # with no usable nvim.
      "$d/bin/nvim" --version >/dev/null 2>&1 \
        || { warn "downloaded nvim does not run here; keeping current version"; continue; }

      # Keep exactly one rollback copy, then converge on the /opt layout.
      # Two layouts exist in the fleet: this box has the /opt symlink, the HTAA
      # boxes have a real binary sitting at /usr/local/bin/nvim. Both end up
      # identical after this runs.
      if [[ -d "$NVIM_PREFIX" ]]; then
        [[ -d "${NVIM_PREFIX}.bak" ]] && sudo rm -rf "${NVIM_PREFIX}.bak"
        sudo mv "$NVIM_PREFIX" "${NVIM_PREFIX}.bak"
        log "  previous install kept at ${NVIM_PREFIX}.bak"
      elif [[ -f /usr/local/bin/nvim && ! -L /usr/local/bin/nvim ]]; then
        sudo mv /usr/local/bin/nvim /usr/local/bin/nvim.bak
        log "  previous binary kept at /usr/local/bin/nvim.bak"
      fi

      sudo mkdir -p "$NVIM_PREFIX" \
        && sudo cp -a "$d"/. "$NVIM_PREFIX"/ \
        && sudo ln -sfn "$NVIM_PREFIX/bin/nvim" /usr/local/bin/nvim \
        && break
    fi
  done
  rm -rf "$tmp"
  if have nvim && ! nvim_outdated; then
    log "  installed $(nvim --version | head -1)"
  else
    note_fail "neovim ($NVIM_VERSION)"
  fi
else
  log "neovim already current: $(nvim --version | head -1)"
fi

if ! have kitty && [[ ! -x "$HOME/.local/bin/kitty" ]]; then
  log "Installing kitty (upstream installer)..."
  curl -sSL https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin >/dev/null 2>&1 \
    || note_fail "kitty"
  # The installer drops kitty.app in ~/.local; these are the launchers.
  ln -sf "$HOME/.local/kitty.app/bin/kitty"  "$HOME/.local/bin/kitty"  2>/dev/null
  ln -sf "$HOME/.local/kitty.app/bin/kitten" "$HOME/.local/bin/kitten" 2>/dev/null
else
  log "kitty already present: $(command -v kitty || echo "$HOME/.local/bin/kitty")"
fi

# =============================================================================
# 2. oh-my-zsh + plugins
#
# The plugins are NOT bundled with oh-my-zsh and are NOT in this repo, so a
# fresh machine has to clone them. Without them .zshrc loads a plugin list that
# does not exist and the shell complains on every startup.
# =============================================================================
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  log "Installing oh-my-zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    || note_fail "oh-my-zsh install"
else
  log "oh-my-zsh already present"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
clone_plugin() {  # clone_plugin <name> <url>
  local dest="$ZSH_CUSTOM/plugins/$1"
  if [[ -d "$dest" ]]; then
    log "plugin ok: $1"
  else
    log "Installing zsh plugin: $1"
    git clone --depth=1 "$2" "$dest" >/dev/null 2>&1 || note_fail "zsh plugin: $1"
  fi
}
clone_plugin zsh-autosuggestions     https://github.com/zsh-users/zsh-autosuggestions
clone_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting
clone_plugin fzf-tab                 https://github.com/Aloxaf/fzf-tab

# =============================================================================
# 3. Powerlevel10k
#
# .zshrc sources it from ~/powerlevel10k (NOT the oh-my-zsh custom themes dir),
# so it must be installed there. Installing it anywhere else leaves the shell
# erroring on every startup — which is exactly what the old bootstrap did.
# =============================================================================
P10K="$HOME/powerlevel10k"
if [[ ! -d "$P10K" ]]; then
  log "Installing powerlevel10k -> $P10K"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K" >/dev/null 2>&1 \
    || note_fail "powerlevel10k"
else
  log "powerlevel10k already present"
fi

# =============================================================================
# 4. Language toolchains
# =============================================================================
if [[ "$SKIP_LANG" == "0" ]]; then
  # uv — fast Python package/venv manager; also provides uvx
  if ! have uv; then
    log "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh >/dev/null 2>&1 || note_fail "uv"
  else
    log "uv already present"
  fi

  # Python dev tools. Installed with uv so they land as isolated tools rather
  # than polluting the system python.
  if have uv; then
    for t in ruff black isort pylint pre-commit ipython yt-dlp; do
      if ! have "$t"; then
        log "Installing python tool: $t"
        uv tool install "$t" >/dev/null 2>&1 || note_fail "uv tool: $t"
      fi
    done
  fi

  # Rust
  if ! have cargo; then
    log "Installing rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y >/dev/null 2>&1 \
      || note_fail "rustup"
  else
    log "rust already present"
  fi

  # Node via nvm (.zshrc already sources ~/.nvm)
  if [[ ! -d "$HOME/.nvm" ]]; then
    log "Installing nvm + node LTS..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash >/dev/null 2>&1 \
      || note_fail "nvm"
    export NVM_DIR="$HOME/.nvm"
    # shellcheck source=/dev/null
    [[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh" && nvm install --lts >/dev/null 2>&1
  else
    log "nvm already present"
  fi

  # vcpkg — C++ dependency manager, used by the Cutlass work
  if [[ ! -d "$HOME/vcpkg" ]]; then
    log "Installing vcpkg..."
    git clone --depth=1 https://github.com/microsoft/vcpkg.git "$HOME/vcpkg" >/dev/null 2>&1 \
      && "$HOME/vcpkg/bootstrap-vcpkg.sh" -disableMetrics >/dev/null 2>&1 \
      || note_fail "vcpkg"
  else
    log "vcpkg already present"
  fi
else
  log "SKIP_LANG=1 — skipping language toolchains"
fi

# =============================================================================
# 5. Standalone binaries
# =============================================================================
# Claude Code
if ! have claude && [[ ! -x "$HOME/.local/bin/claude" ]]; then
  log "Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash >/dev/null 2>&1 || note_fail "claude"
else
  log "claude already present"
fi

# gitleaks — REQUIRED: the dotfiles pre-commit hook refuses to commit without it
if ! have gitleaks && [[ ! -x "$HOME/.local/bin/gitleaks" ]]; then
  log "Installing gitleaks..."
  GL_VER="8.30.1"
  curl -sSL "https://github.com/gitleaks/gitleaks/releases/download/v${GL_VER}/gitleaks_${GL_VER}_linux_x64.tar.gz" \
    | tar -xz -C "$HOME/.local/bin" gitleaks 2>/dev/null || note_fail "gitleaks"
  chmod +x "$HOME/.local/bin/gitleaks" 2>/dev/null
else
  log "gitleaks already present"
fi

# glab — GitLab CLI. Not in the Ubuntu repos; the internal GitLab
# (git.hulltactical.net) is easier to query with it than raw curl.
# Point it at the internal host with:  glab auth login --hostname git.hulltactical.net
if ! have glab && [[ ! -x "$HOME/.local/bin/glab" ]]; then
  log "Installing glab..."
  GLAB_VER="1.68.0"
  tmp=$(mktemp -d)
  curl -sSL "https://gitlab.com/gitlab-org/cli/-/releases/v${GLAB_VER}/downloads/glab_${GLAB_VER}_linux_amd64.tar.gz" \
    | tar -xz -C "$tmp" 2>/dev/null \
    && mv "$tmp/bin/glab" "$HOME/.local/bin/" 2>/dev/null \
    || note_fail "glab"
  rm -rf "$tmp"
else
  log "glab already present"
fi

# age — encrypts the vault backup snapshots on usb2
if ! have age && [[ ! -x "$HOME/.local/bin/age" ]]; then
  log "Installing age..."
  AGE_VER="1.2.1"
  tmp=$(mktemp -d)
  curl -sSL "https://github.com/FiloSottile/age/releases/download/v${AGE_VER}/age-v${AGE_VER}-linux-amd64.tar.gz" \
    | tar -xz -C "$tmp" 2>/dev/null \
    && mv "$tmp"/age/age "$tmp"/age/age-keygen "$HOME/.local/bin/" 2>/dev/null \
    || note_fail "age"
  rm -rf "$tmp"
else
  log "age already present"
fi

# =============================================================================
# 6. Private repo, then symlinks
#
# The private repo needs an SSH key that GitHub already knows about, so on a
# truly fresh machine this fails the first time. That is expected — generate a
# key, add it to GitHub, and re-run.
# =============================================================================
if [[ ! -d "$PRIVATE_DIR/.git" ]]; then
  log "Cloning private repo..."
  if ! git clone "$PRIVATE_REMOTE" "$PRIVATE_DIR" >/dev/null 2>&1; then
    note_fail "private repo clone (no SSH key on this machine yet?)"
    warn "  ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_github_personal"
    warn "  then add the .pub at https://github.com/settings/keys and re-run"
  fi
else
  log "private repo already present"
fi

log "Running install.sh..."
LINK_SSH=1 bash "$DOTFILES/install.sh" || note_fail "install.sh reported conflicts — review above"

# =============================================================================
# 7. Plugin managers and caches
# =============================================================================
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  log "Cloning TPM..."
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" >/dev/null 2>&1 \
    || note_fail "tpm"
fi

if have nvim; then
  log "Syncing nvim plugins..."
  nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1 || warn "nvim Lazy sync had issues"
fi

if [[ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]]; then
  log "Installing tmux plugins..."
  "$HOME/.tmux/plugins/tpm/bin/install_plugins" >/dev/null 2>&1 || warn "tmux plugin install had issues"
fi

log "Refreshing font cache..."
fc-cache -f "$HOME/.fonts" >/dev/null 2>&1 || true

# =============================================================================
# 8. Shell
# =============================================================================
# Compare RESOLVED paths: /bin/zsh and /usr/bin/zsh are the same binary on a
# usr-merged system, and comparing the raw strings would prompt for a password
# on every re-run of an already-correct machine.
if have zsh; then
  current_shell=$(readlink -f "$(getent passwd "$USER" | cut -d: -f7)" 2>/dev/null)
  want_shell=$(readlink -f "$(command -v zsh)" 2>/dev/null)
  if [[ "$current_shell" != "$want_shell" ]]; then
    log "Default shell is $current_shell — changing to zsh (prompts for your password)"
    chsh -s "$(command -v zsh)" || note_fail "chsh — run 'chsh -s $(command -v zsh)' manually"
  else
    log "Default shell already zsh"
  fi
fi

# =============================================================================
# 9. systemd user timers
#
# Units live in the PRIVATE repo and install.sh symlinks ~/.config/systemd/user
# at it. They reference absolute paths under /home/laurent and hardware (USB
# mount points, the VPN), so they are NOT enabled automatically here — review
# before switching them on.
# =============================================================================
systemctl --user daemon-reload 2>/dev/null || true
if [[ -d "$PRIVATE_DIR/systemd-user" ]]; then
  log "systemd units available: $(ls "$PRIVATE_DIR"/systemd-user/*.timer 2>/dev/null | wc -l) timers"
  log "  review, then: systemctl --user enable --now <name>.timer"
fi

# =============================================================================
log ""
log "=========================================="
if ((${#FAILURES[@]})); then
  warn "${#FAILURES[@]} step(s) failed:"
  for f in "${FAILURES[@]}"; do warn "  - $f"; done
  log ""
fi
log "Bootstrap done. Manual follow-ups:"
log "  - gh auth login                    (if not signed in)"
log "  - SSH keys are NOT tracked anywhere — generate or transfer them:"
log "      id_ed25519_github_personal  -> GitHub lanteignel93"
log "      id_ed25519_github_htaabp    -> GitHub laurentHull93"
log "  - edit ~/.gitconfig.local if this is a WORK machine (Hull identity)"
log "  - echo '<topic>' > ~/.config/ntfy/topic   (phone alerts; chmod 600)"
log "  - p10k configure                   (only to change the prompt)"
log "  - log out and back in to land in zsh"
log "=========================================="
((${#FAILURES[@]} == 0))
