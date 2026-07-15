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

if [[ "$DRY_RUN" == "0" ]]; then
  mkdir -p "$BACKUP_DIR"
fi

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

link "$DOTFILES/systemd-user" "$HOME/.config/systemd/user"

if [[ "$LINK_SSH" == "1" ]]; then
  [[ -d "$PRIVATE/.git" ]] || fail "$PRIVATE is not a git repo (needed for ssh symlink)"
  link "$PRIVATE/ssh/config" "$HOME/.ssh/config"
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
