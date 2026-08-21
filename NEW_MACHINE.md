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

### 0. Connect — terminfo first, or tmux won't run

You connect from kitty, which exports `TERM=xterm-kitty`. A fresh box has no
kitty terminfo entry, so the first thing you'll see is:

```
missing or unsuitable terminal: xterm-kitty
```

tmux, vim and anything else curses-based refuse to start. Nothing is broken —
the remote just doesn't have the terminal description.

**Best: connect with kitty's own wrapper**, which ships terminfo across for you:

```sh
kitten ssh 141htaaprd5
```

**Or fix the box once** — with sudo:

```sh
sudo apt install -y kitty-terminfo
```

…or without, pushed from a box that has it:

```sh
infocmp -a xterm-kitty | ssh NEWBOX 'tic -x -o ~/.terminfo /dev/stdin'
```

**One-off escape hatch** if you just need a shell right now:

```sh
TERM=xterm-256color tmux
```

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

On an **HTAA box** you'd rather not put the personal pair on company hardware —
but note that `dot_files` and `private_configs` both live under `lanteignel93`,
and the `insteadOf` rewrite sends them over SSH, so without the personal key you
cannot even `git pull` your own dotfiles there. Make that trade knowingly.

### 2b. Write a minimal `~/.ssh/config` — the step everyone forgets

**Copying keys is not enough.** The keys are named `id_ed25519_github_personal`,
`…_htaabp`, `…_gitlab_hull`. SSH only tries `id_rsa` / `id_ecdsa` / `id_ed25519`
by default, so with no config it offers **nothing** and GitHub answers
`Permission denied (publickey)` — looking exactly like a missing or bad key.

The real config is per-machine and lives in `dotfiles-private/ssh/`, which you
cannot clone yet, because cloning it needs the config. Break the loop with a
minimal one:

```sh
cat > ~/.ssh/config <<'EOF'
# Minimal bootstrap config. Replaced by the private repo's per-machine file
# once dotfiles-private is cloned (install.sh symlinks it).

Host github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github_personal
    IdentitiesOnly yes

Host github-htaabp
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github_htaabp
    IdentitiesOnly yes

Host git.hulltactical.net gitlab-hull
    HostName git.hulltactical.net
    User git
    IdentityFile ~/.ssh/id_ed25519_gitlab_hull
    IdentitiesOnly yes
EOF

chmod 600 ~/.ssh/config
```

**Verify before continuing. This gate is the whole point of the runbook:**

```sh
ssh -T git@github.com          # -> Hi lanteignel93!
ssh -T git@github-htaabp       # -> Hi laurentHull93!
```

If `github.com` greets you as the **wrong account**, that box is answering with
a key held by the agent rather than the one configured. `IdentitiesOnly yes`
restricts ssh to configured keys but does not choose among what the agent
offers — add `IdentityAgent none` to that Host block to actually pin it.

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

## Not covered by bootstrap — the secrets

`bootstrap.sh` gets you a working **environment**. It does not get you a working
**identity**, and it cannot give you access to encrypted data. None of the
following live in any repo — by design — so a box that bootstraps perfectly is
still incomplete until these are placed by hand.

| File / action | What breaks without it |
|---|---|
| `~/.gitconfig.local` | commits stamped with the wrong identity — silently |
| `~/.config/ntfy/topic` | phone alerts do nothing, with no error |
| `~/.config/age/keys.txt` | **cannot decrypt any usb2 vault snapshot** |
| `~/dotfiles/vpn-ssh/secrets` | `vpn` / `ssh-connect` fail (install.sh only copies an empty template) |
| `~/.config/git-mirror/gitlab-token` | GitLab repo discovery for mirroring |
| `gh auth login` | `gh` unusable |
| systemd timers | installed but **deliberately not enabled** — they hardcode `/home/laurent` paths and USB mounts. Review before switching any on |
| your desktop key in the new box's `~/.ssh/authorized_keys` | every future remote check needs a password |

**The `age` key is the one with teeth.** Per `Vault Backup and Recovery`, it is
a single point of failure: it lives on the laptop and on usb1, and losing both
makes every usb2 snapshot permanently unreadable. There is no reset. Only place
it on a machine that actually needs to read backups.

Two of these fail **silently** — a wrong git identity and a dead ntfy topic both
look exactly like success. Verify them rather than assuming.

## Verify it actually worked

Bootstrap reporting "done" is not evidence. Check outcomes:

```sh
ssh -T git@github.com                      # Hi lanteignel93!
git config --get user.email                # the RIGHT identity for this box
ls -la ~/.zshrc                            # symlink -> ~/dotfiles/.zshrc
ls ~/.local/share/nvim/lazy | wc -l        # ~60, not 0
ls ~/.tmux/plugins/tpm                     # not empty
ls -d ~/dotfiles-private/.git              # private repo landed
nvim --version | head -1                   # v0.12.4
tmux -V                                    # runs at all -> terminfo is fine
echo $EDITOR                               # nvim, not empty
echo $SHELL                                # or: log out, log in, expect zsh
```

---

## Traps, with the evidence

| Trap | Symptom | Why |
|---|---|---|
| **`insteadOf` with no key** | `Permission denied (publickey)` on an https clone | `.gitconfig` rewrites https→SSH; bites everything after step 6 |
| **Keys copied, no `~/.ssh/config`** | `Permission denied (publickey)` *with the keys sitting right there* | keys are named `id_ed25519_github_personal` etc.; ssh only tries `id_rsa`/`id_ecdsa`/`id_ed25519` by default, so it offers nothing. See step 2b |
| **Wrong account answers** | `ssh -T git@github.com` greets the other identity | `IdentitiesOnly yes` limits ssh to configured keys but doesn't override what the agent offers first — add `IdentityAgent none` |
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
