# zsh setup prompt

This file holds a prompt to paste into Claude Code (or any AI coding assistant) the **first time** you set up this dotfiles repo on a new machine. It performs the same zsh wiring that exists on the source machine — symlinks, per-machine config seed, and migration of any unique lines from the machine's existing `~/.zshrc`.

You can also follow it manually (see "Manual fallback" at the bottom) if you'd rather not use an assistant.

---

## Copy-paste prompt

> I just cloned my dotfiles repo at `~/dotfiles`. I want my zsh on this machine to load config from `~/dotfiles/zsh/` exactly like the source machine, while keeping anything machine-specific separate.
>
> Please do the following, in order, and stop to ask me before any step that would discard data:
>
> 1. **Read** `~/dotfiles/zsh/zshrc`, `~/dotfiles/zsh/zshenv`, `~/dotfiles/zsh/aliases.zsh`, `~/dotfiles/zsh/functions.zsh`, `~/dotfiles/zsh/lazy.zsh`, and `~/dotfiles/zsh/local.zsh.example` so you understand the module layout.
>
> 2. **Inspect** my current `~/.zshrc` (and `~/.zshenv` if it exists). Identify lines that are **not** already covered by the dotfiles zsh modules. Treat these as machine-specific:
>    - Custom PATH entries pointing at machine-only tools (e.g. work tools, JetBrains Toolbox, Antigravity, Cargo bin)
>    - API keys / secrets / tokens
>    - Aliases that reference machine-specific paths or directories that exist on this machine only
>    - Theme overrides
>
> 3. **Show** me the list of machine-specific lines you found. Wait for me to confirm or edit the list before continuing.
>
> 4. **Back up** my existing `~/.zshrc` to `~/.zshrc.bak` (and `~/.zshenv` to `~/.zshenv.bak` if it exists). Skip the move if the file is already a symlink pointing at the dotfiles version.
>
> 5. **Create symlinks**:
>    - `~/.zshrc` → `~/dotfiles/zsh/zshrc`
>    - `~/.zshenv` → `~/dotfiles/zsh/zshenv`
>    Use `ln -sf`.
>
> 6. **Create** `~/.zshrc.local` from `~/dotfiles/zsh/local.zsh.example` (only if `~/.zshrc.local` does not already exist), then paste the machine-specific lines from step 3 into it.
>
> 7. **Verify**: run `ls -la ~/.zshrc ~/.zshenv` and confirm both show `->` pointing into `~/dotfiles/zsh/`. Run `zsh -n ~/.zshrc` to syntax-check.
>
> 8. **Report**: print a short summary of what changed, what's now in `~/.zshrc.local`, and remind me to run `exec zsh` to reload.
>
> Do NOT install Homebrew, run brew, modify `.zprofile`, or touch any non-zsh dotfiles — those are handled by `init_setup.sh` separately.

---

## Manual fallback

If you'd rather do it by hand, the entire flow is:

```sh
# 1. Compare your current zshrc to the dotfiles version, note the diff
diff -u ~/.zshrc ~/dotfiles/zsh/zshrc | less

# 2. Back up existing
[ -f ~/.zshrc ]  && mv ~/.zshrc  ~/.zshrc.bak
[ -f ~/.zshenv ] && mv ~/.zshenv ~/.zshenv.bak

# 3. Symlink dotfiles modules in
ln -sf ~/dotfiles/zsh/zshrc  ~/.zshrc
ln -sf ~/dotfiles/zsh/zshenv ~/.zshenv

# 4. Seed per-machine override file
[ ! -f ~/.zshrc.local ] && cp ~/dotfiles/zsh/local.zsh.example ~/.zshrc.local

# 5. Open ~/.zshrc.local in your editor, paste machine-specific lines from the
#    diff in step 1 (work tools, API keys, Toolbox path, etc.)
$EDITOR ~/.zshrc.local

# 6. Reload
exec zsh
```

---

## What lives where

| File | Owner | Tracked in git? |
|---|---|---|
| `~/dotfiles/zsh/*` | dotfiles repo | yes |
| `~/.zshrc` | symlink → dotfiles | n/a (it's a symlink) |
| `~/.zshenv` | symlink → dotfiles | n/a |
| `~/.zshrc.local` | this machine only | **no** — outside repo |
| `~/.zshenv.local` | this machine only (optional) | **no** |
| `~/.zshrc.bak` | one-time backup of pre-install zshrc | **no** |

`~/.zshrc.local` is sourced at the very end of the dotfiles `zshrc`, so anything in it can override or append to the shared config.
