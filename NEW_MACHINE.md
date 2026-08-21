# Setting up a new machine

Runbook for provisioning a box from this repo. Written 2026-08-21 after
`141htaaprd5` surfaced four separate failures that all traced back to doing
things in the wrong order.

---

## The one rule: keys first

**Get SSH keys onto the box before you clone anything.**

The tracked `.gitconfig` contains:

```ini
[url "git@github.com:"]
    insteadOf = https://github.com/
```

That rewrites **every** `https://github.com/` URL to SSH. It is correct on an
established machine — everything uses SSH, one identity, no password prompts.
But it means that the moment `install.sh` symlinks that file, **https access to
GitHub stops working entirely** until a key exists.

The old instructions said "clone over https, there's no key yet." That works for
exactly one command and then poisons everything after it. On prd5 it took out
the private repo, TPM, and all 59 nvim plugins, each reporting
`Permission denied (publickey)` from a step that had nothing obviously to do
with SSH.

`bootstrap.sh` now detects this at startup and routes clones around it, so a
no-key run degrades instead of collapsing. Don't rely on that — it cannot fix
the private repo, which is SSH-only.

---

## Order

### 1. Prereqs

```sh
sudo apt install -y git curl      # debian/ubuntu
sudo dnf install -y git curl      # fedora
```

### 2. Keys — before anything else

Either **generate** a per-machine key (the documented policy; see
`Important Stuff/Git Identities` in the vault):

```sh
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_github_personal -C "$(hostname)"
cat ~/.ssh/id_ed25519_github_personal.pub    # add at github.com/settings/keys
```

…or **copy** them from an existing box, preserving permissions. Use `tar` over a
pipe, not `scp` — plain `scp` applies the default umask and ssh then refuses the
key as world-readable:

```sh
# run FROM the box that has the keys
tar -C ~ -czf - \
  .ssh/id_ed25519_github_personal .ssh/id_ed25519_github_personal.pub \
  .ssh/id_ed25519_github_htaabp   .ssh/id_ed25519_github_htaabp.pub \
  .ssh/id_ed25519_gitlab_hull     .ssh/id_ed25519_gitlab_hull.pub \
| ssh NEWBOX 'mkdir -p ~/.ssh && chmod 700 ~/.ssh && tar -C ~ -xzf -'
```

On an **HTAA box, drop the personal pair** — that puts your personal GitHub
identity on company hardware you don't control.

**Verify before continuing. This gate is the whole point of the runbook:**

```sh
ssh -T git@github.com          # -> Hi lanteignel93!
```

### 3. Clone over SSH

```sh
git clone git@github.com:lanteignel93/dot_files.git ~/dotfiles
```

Not https. With a key present, SSH is what the rewrite wants anyway.

### 4. Bootstrap

```sh
bash ~/dotfiles/bootstrap.sh
```

First line of output tells you whether the key was found. If it says
`No working GitHub SSH key`, stop and fix step 2 — don't push through.

### 5. Log out and back in

That is what lands you in zsh. On boxes where you are a **directory-managed
user** (all HTAA boxes — `llanteigne` is not in `/etc/passwd`), `chsh` cannot
work at all; bootstrap installs a `~/.bash_profile` handoff instead. Either way
it only takes effect on a fresh login.

### 6. Finish up

- **tmux**: `prefix + I`
- **nvim**: first launch installs plugins from `lazy-lock.json`
- **`~/.gitconfig.local`**: set the Hull identity **before committing anything**
  if this is a work box
- **ntfy**: `echo '<topic>' > ~/.config/ntfy/topic && chmod 600 ~/.config/ntfy/topic`
- **systemd timers**: deliberately not enabled — they hardcode `/home/laurent`
  paths and USB mounts. Review first.

---

## Verify it actually worked

Bootstrap reporting "done" is not evidence. Check outcomes:

```sh
ssh -T git@github.com                      # Hi lanteignel93!
ls -la ~/.zshrc                            # symlink -> ~/dotfiles/.zshrc
ls ~/.local/share/nvim/lazy | wc -l        # ~60, not 0
ls ~/.tmux/plugins/tpm                     # not empty
ls -d ~/dotfiles-private/.git              # private repo landed
nvim --version | head -1                   # v0.12.4
echo $SHELL                                # or: log out, log in, expect zsh
```

---

## Traps, with the evidence

| Trap | Symptom | Why |
|---|---|---|
| **`insteadOf` with no key** | `Permission denied (publickey)` on an https clone | `.gitconfig` rewrites https→SSH; bites everything after step 6 |
| **oh-my-zsh overwrites `.zshrc`** | `install.sh` logs CONFLICT, your config never links, shell looks stock | its installer writes a template `.zshrc`; fixed with `KEEP_ZSHRC=yes` |
| **`chsh` on an LDAP box** | `user 'x' does not exist in /etc/passwd` | `chsh` only edits `/etc/passwd`; use the `.bash_profile` handoff |
| **`exa` on Ubuntu 24.04** | `pkg: exa` fails | 24.04 replaced it with the `eza` fork; bootstrap now picks per release |
| **nvim install layout differs** | upgrade commands from one box fail on another | some boxes symlink `/opt/nvim`, others have a real binary in `/usr/local` or an rpm in `/usr/bin` — **check per box** |
| **Silent plugin failure** | "Syncing nvim plugins..." then nothing works | `Lazy! sync` exits 0 even when every clone fails; bootstrap now counts what landed |

---

## Fleet is not uniform — check before you script

Eleven HTAA hosts, and they differ in ways that break copy-pasted commands:

- **distro**: Ubuntu 24.04 and Fedora both present
- **home**: local ext4 per box, **not** NFS — per-machine changes are per-machine
- **dotfiles path**: `~/dotfiles` on the desktop, `~/.config/laurent_dots` on HTAA
- **nvim**: `/opt` symlink, `/usr/local` real binary, or `/usr/bin` rpm
- **user**: local on the desktop, directory-managed on HTAA

Before running anything across boxes, confirm the shape of each:

```sh
for h in <hosts>; do
  echo "== $h"
  ssh "$h" 'echo "  $(. /etc/os-release; echo $PRETTY_NAME)";
            echo "  nvim: $(readlink -f "$(command -v nvim)" 2>/dev/null)";
            echo "  local user: $(grep -qc "^$USER:" /etc/passwd && echo yes || echo no)"'
done
```

---

## The recurring bug class

Two incidents in two weeks, same root cause: **checking whether a command
finished instead of whether it worked.**

- `usb-backup`: `rsync … || true`, exit 0, "success" logged while it deleted
  both good snapshots.
- `bootstrap`: `Lazy! sync` exits 0 with 59/59 clones failed.

When adding a step here, assert on the **artifact** — the file exists, the count
is right, the marker was written — not on the exit code.
