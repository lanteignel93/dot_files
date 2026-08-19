#!/usr/bin/env bash
# Idempotent dotfiles installer.
# Replaces real files/dirs in $HOME with symlinks pointing at this repo.
# Safe to re-run. Backs up anything it replaces to ~/dotfiles-backup-<timestamp>/.
#
# Usage:
#   bash ~/dotfiles/install.sh           # normal run
#   DRY_RUN=1 bash ~/dotfiles/install.sh # preview only, no changes
#   LINK_SSH=1 bash ~/dotfiles/install.sh # also symlink ~/.ssh/config from dotfiles-private

set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
PRIVATE="${PRIVATE:-$HOME/dotfiles-private}"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$HOME/dotfiles-backup-$STAMP"
DRY_RUN="${DRY_RUN:-0}"
LINK_SSH="${LINK_SSH:-0}"

CONFLICTS=0

log()  { printf '[install] %s\n' "$*"; }
warn() { printf '[install][WARN] %s\n' "$*" >&2; }
fail() { printf '[install][FAIL] %s\n' "$*" >&2; exit 1; }

[[ -d "$DOTFILES/.git" ]] || fail "$DOTFILES is not a git repo"

if [[ -n "$(git -C "$DOTFILES" status --porcelain 2>/dev/null)" ]]; then
  fail "$DOTFILES has uncommitted changes. Commit or stash, then rerun."
fi

# Created lazily by ensure_backup_dir, not up front — an unconditional mkdir
# left an empty dotfiles-backup-<stamp>/ behind on every clean re-run.
ensure_backup_dir() { [[ -d "$BACKUP_DIR" ]] || mkdir -p "$BACKUP_DIR"; }

# Usage: link <src-in-repo> <dest-in-home>
link() {
  local src="$1" dest="$2"

  if [[ ! -e "$src" ]]; then
    warn "missing in repo: $src — skipping"
    return 0
  fi

  if [[ -L "$dest" ]] && [[ "$(readlink -f "$dest")" == "$(readlink -f "$src")" ]]; then
    log "ok       $dest"
    return 0
  fi

  if [[ -L "$dest" ]]; then
    log "relink   $dest (was -> $(readlink "$dest"))"
    if [[ "$DRY_RUN" == "1" ]]; then return 0; fi
    rm "$dest"
    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    return 0
  fi

  if [[ -e "$dest" ]]; then
    if diff -qr "$dest" "$src" >/dev/null 2>&1; then
      log "match    $dest (identical to repo; converting to symlink)"
    else
      local home_mtime repo_mtime
      home_mtime=$(stat -c %Y "$dest" 2>/dev/null || echo 0)
      repo_mtime=$(stat -c %Y "$src" 2>/dev/null || echo 0)
      if (( home_mtime < repo_mtime )); then
        warn "stale    $dest (older than repo; taking repo version)"
      else
        warn "CONFLICT $dest is newer-or-equal AND differs from $src"
        warn "         Resolve manually: diff -r '$dest' '$src'"
        warn "         To keep home's version: copy it into the repo, commit, then rerun."
        CONFLICTS=$((CONFLICTS + 1))
        return 0
      fi
    fi

    if [[ "$DRY_RUN" == "1" ]]; then
      log "DRY-RUN  would backup+link $dest"
      return 0
    fi
    ensure_backup_dir
    local rel="${dest#$HOME/}"
    mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    mv "$dest" "$BACKUP_DIR/$rel"
  fi

  if [[ "$DRY_RUN" == "1" ]]; then
    log "DRY-RUN  would link $dest -> $src"
    return 0
  fi

  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  log "linked   $dest -> $src"
}

log "DOTFILES=$DOTFILES"
log "BACKUP_DIR=$BACKUP_DIR  (DRY_RUN=$DRY_RUN)"
log ""

link "$DOTFILES/.zshrc"      "$HOME/.zshrc"
link "$DOTFILES/.zshenv"     "$HOME/.zshenv"
link "$DOTFILES/.bashrc"     "$HOME/.bashrc"
link "$DOTFILES/.p10k.zsh"   "$HOME/.p10k.zsh"
link "$DOTFILES/.profile"    "$HOME/.profile"
link "$DOTFILES/.gitconfig"  "$HOME/.gitconfig"
link "$DOTFILES/.tmux.conf"  "$HOME/.tmux.conf"

link "$DOTFILES/.tmux"  "$HOME/.tmux"
link "$DOTFILES/.fonts" "$HOME/.fonts"

for app in nvim kitty alacritty awesome polybar nitrogen lazygit htop neofetch bottom gtk-4.0 tuicr; do
  link "$DOTFILES/$app" "$HOME/.config/$app"
done

# Global git ignore. .gitconfig sets core.excludesfile=~/.gitignore, which
# pointed at a file that was never tracked — so the rule silently vanished on
# any new machine.
link "$DOTFILES/gitignore_global" "$HOME/.gitignore"

# systemd user units moved to the PRIVATE repo on 2026-08-18: this repo is
# public, and the units name internal hosts, mount points, backup paths and the
# ntfy alert topic. Linking from $DOTFILES here silently did nothing.
if [[ -d "$PRIVATE/systemd-user" ]]; then
  link "$PRIVATE/systemd-user" "$HOME/.config/systemd/user"
else
  warn "no $PRIVATE/systemd-user — clone the private repo to get the timers"
fi

# vpn/ssh-connect tools: config dir symlinked whole; real secrets file is
# gitignored, so bootstrap it from the template on a fresh machine
link "$DOTFILES/vpn-ssh" "$HOME/.config/vpn-ssh"
link "$DOTFILES/vpn-ssh/vpn.sh"         "$HOME/.local/bin/vpn"
link "$DOTFILES/vpn-ssh/ssh_connect.sh" "$HOME/.local/bin/ssh-connect"
if [[ "$DRY_RUN" == "0" && ! -f "$DOTFILES/vpn-ssh/secrets" ]]; then
  cp "$DOTFILES/vpn-ssh/secrets.example" "$DOTFILES/vpn-ssh/secrets"
  chmod 600 "$DOTFILES/vpn-ssh/secrets"
  warn "vpn-ssh: created secrets from template — fill in $DOTFILES/vpn-ssh/secrets"
fi

if [[ "$DRY_RUN" == "0" ]]; then
  git -C "$DOTFILES" config core.hooksPath hooks
  log "hooks    core.hooksPath = hooks (gitleaks pre-commit)"
  command -v gitleaks >/dev/null 2>&1 || warn "gitleaks not on PATH — pre-commit hook will refuse commits until installed"
fi

# ---------------------------------------------------------------------------
# ssh config is PER MACHINE, not shared.
#
# Each box holds its own key material for the same identities (private keys
# never travel), so one shared config would point at key files that do not
# exist on the other machine. The private repo keeps one config per host:
#   ssh/laurent-dell-desktop.config
#   ssh/htaa-work.config
#
# Override the choice with SSH_CONFIG_NAME=<name> for a machine not listed.
# ---------------------------------------------------------------------------
if [[ "$LINK_SSH" == "1" ]]; then
  [[ -d "$PRIVATE/.git" ]] || fail "$PRIVATE is not a git repo (needed for ssh symlink)"
  ssh_name="${SSH_CONFIG_NAME:-$(hostname)}"
  ssh_src="$PRIVATE/ssh/${ssh_name}.config"
  if [[ -f "$ssh_src" ]]; then
    link "$ssh_src" "$HOME/.ssh/config"
  else
    warn "no ssh config for host '${ssh_name}' in $PRIVATE/ssh/"
    warn "  available: $(cd "$PRIVATE/ssh" 2>/dev/null && ls *.config 2>/dev/null | sed 's/\.config$//' | tr '\n' ' ')"
    warn "  pick one with: SSH_CONFIG_NAME=<name> LINK_SSH=1 bash $0"
    warn "  or add ${ssh_name}.config to the private repo for this machine."
    CONFLICTS=$((CONFLICTS + 1))
  fi
fi

# ---------------------------------------------------------------------------
# Machine-local git identity. NOT tracked anywhere — it is what makes the
# shared .gitconfig safe to use on both personal and work machines.
# Absent, git falls back to the personal address for everything.
# ---------------------------------------------------------------------------
if [[ "$DRY_RUN" == "0" && ! -f "$HOME/.gitconfig.local" ]]; then
  cat > "$HOME/.gitconfig.local" <<'GITLOCAL'
# Machine-local git config — deliberately untracked, differs per machine.
# The shared ~/.gitconfig includes this file, and later values win, so
# anything set here overrides the shared defaults on THIS box only.
#
# On a work machine, make the work identity the default:
#   [user]
#       email = laurent@hulltactical.com
#   [github]
#       user = "laurentHull93"
GITLOCAL
  log "created  ~/.gitconfig.local (stub — edit if this is a work machine)"
fi

log ""
if (( CONFLICTS > 0 )); then
  warn "$CONFLICTS conflict(s) skipped — review messages above"
  exit 2
fi

if [[ "$DRY_RUN" == "1" ]]; then
  log "DRY-RUN complete. Re-run without DRY_RUN=1 to apply."
else
  log "done. Backup at: $BACKUP_DIR"
fi
