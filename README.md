# dotfiles

macOS developer environment: AeroSpace + Sketchybar + Neovim + tmux + navi cheatsheets.

## What's included

| Directory / File | Symlink target | Tool |
|---|---|---|
| `aerospace/aerospace.toml` | `~/.aerospace.toml` | Window manager |
| `sketchybar/` | `~/.config/sketchybar/` | Status bar |
| `borders/bordersrc` | `~/.config/borders/bordersrc` | Window borders |
| `nvim/` | `~/.config/nvim/` | Neovim config |
| `tmux/tmux.conf` | `~/.tmux.conf` | Terminal multiplexer |
| `navi/` | `~/.config/navi/` | Cheatsheet tool config |
| `cheatsheets/` | referenced by navi | Keybinding cheat sheets |

---

## Quick start (new Mac)

```bash
git clone git@github.com:akimdev15/dotfiles.git ~/dotfiles
~/dotfiles/init_setup.sh
```

`init_setup.sh` installs Homebrew dependencies, creates all symlinks, makes scripts executable, and starts services. Existing configs are backed up as `*.bak`.

---

## Post-install steps

### 1. Hide native menu bar (required for sketchybar)
System Settings → Desktop & Dock → Menu Bar → **Automatically hide and show the menu bar → Always**

### 2. Grant Accessibility permission (required for AeroSpace)
System Settings → Privacy & Security → Accessibility → add **AeroSpace**

> If AeroSpace doesn't appear in the list, click **+** and navigate to:
> `/opt/homebrew/Caskroom/nikitabobko-aerospace/<version>/AeroSpace.app`
> Press `Cmd-Shift-G` in the Finder dialog to jump to a path.

### 3. Reload AeroSpace config
`Alt-Shift-;` then `Esc`

### 4. Set up Neovim
Open `nvim` and run:
```
:Lazy sync
```
Then install LSP servers:
```
:MasonInstall lua-language-server pyright jdtls
```
Then authorize Copilot:
```
:Copilot auth
```

### 5. Set up tmux plugins
Inside a tmux session, press `prefix + I` (capital i) to install plugins via TPM.

---

## Tool setup guides

### AeroSpace (window manager)

AeroSpace is a tiling window manager for macOS. Config lives at `aerospace/aerospace.toml`.

**Key bindings:**

| Binding | Action |
|---|---|
| `Alt-h/j/k/l` | Focus window (wraps across monitors) |
| `Alt-Shift-h/j/k/l` | Move window |
| `Alt-1..9` | Switch workspace |
| `Alt-Shift-1..9` | Move window to workspace (follows) |
| `Alt-Tab` | Toggle last workspace |
| `Alt-Shift-Tab` | Move workspace to next monitor |
| `Alt-Ctrl-←/→/↑/↓` | Move window to another monitor |
| `Alt-Ctrl-f` | Toggle floating / tiling |
| `Alt-Ctrl-Shift-f` | Fullscreen |
| `Alt-/` | Layout: tiles |
| `Alt-,` | Layout: accordion |
| `Alt-Shift--/=` | Resize smart |
| `Alt-Shift-Space` | Open cheatsheet popup |

**App shortcuts:**

| Binding | App |
|---|---|
| `Alt-g` | Ghostty |
| `Alt-o` | Obsidian |
| `Alt-f` | Finder |
| `Alt-i` | IntelliJ IDEA |
| `Alt-b` | Brave Browser |
| `Alt-v` | VS Code |

**Modes:**

| Binding | Mode |
|---|---|
| `Alt-Shift-;` | Service mode (then `Esc` = reload, `r` = flatten, `f` = float, `backspace` = close others) |
| `Alt-Shift-Enter` | Apps mode |

---

### Sketchybar (status bar)

Custom status bar showing: workspace indicators, front app, media, pomodoro, wifi, bluetooth, battery, CPU/memory, calendar.

Config lives at `sketchybar/sketchybarrc` with items in `sketchybar/items/` and plugins in `sketchybar/plugins/`.

Restart sketchybar: `brew services restart sketchybar`

---

### Neovim

Config at `nvim/`. Built on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) with custom plugins.

**Key bindings (leader = Space):**

| Binding | Action |
|---|---|
| `Ctrl-h/j/k/l` | Navigate windows / tmux panes |
| `<leader>e` | Float file explorer (neo-tree) |
| `<leader>t` | Sidebar file explorer (neo-tree) |
| `<leader>ff` | Find files (Telescope) |
| `<leader>fg` | Live grep |
| `<leader>fb` | Find buffer |
| `<leader>sw` | Search current word |
| `<leader>s.` | Recent files |
| `<leader>/` | Fuzzy search current buffer |
| `<leader><leader>` | All open buffers |
| `gd` | Go to definition (LSP) |
| `gr` | Go to references (LSP) |
| `gI` | Go to implementation (LSP) |
| `<leader>rn` | Rename symbol (LSP) |
| `<leader>ca` | Code action (LSP) |
| `gl` | Show line diagnostics |
| `[d` / `]d` | Prev / next diagnostic |
| `gcc` | Toggle line comment |
| `gc` (visual) | Toggle comment selection |

**Copilot (insert mode):**

| Binding | Action |
|---|---|
| `Ctrl-f` | Accept whole suggestion |
| `Alt-w` | Accept one word |
| `Alt-j` | Accept one line |
| `Alt-]` / `Alt-[` | Next / prev suggestion |
| `Ctrl-]` | Dismiss |

---

### tmux

Config at `tmux/tmux.conf`. Prefix: `Ctrl-Space`.

**Sessions / windows:**

| Binding | Action |
|---|---|
| `prefix + t` | Scratch popup toggle |
| `Ctrl-t` | Close scratch (from inside scratch) |
| `Alt-H` / `Alt-L` | Prev / next window |
| `prefix + c` | New window |
| `prefix + ,` | Rename window |
| `prefix + r` | Reload config |

**Panes:**

| Binding | Action |
|---|---|
| `prefix + "` | Split horizontal (current dir) |
| `prefix + %` | Split vertical (current dir) |
| `Ctrl-h/j/k/l` | Navigate panes (shared with nvim) |
| `prefix + H/J/K/L` | Resize pane (hold to repeat) |
| `prefix + x` | Kill pane |

**Copy mode (vi keys):**

| Binding | Action |
|---|---|
| `prefix + [` | Enter copy mode |
| `v` | Start selection |
| `y` | Copy to clipboard |

---

### Navi (cheatsheet popup)

[navi](https://github.com/denisidoro/navi) is a fuzzy-searchable cheatsheet tool. Cheat files live at `cheatsheets/` and are referenced by `navi/config.yaml`.

**Opening the popup:**

| Method | Trigger |
|---|---|
| tmux popup | `prefix + ?` |

**Inside navi:**
- Type to fuzzy-search descriptions
- `Enter` — use/execute the selected entry
- `Esc` — close without selecting

**Adding cheat sheets:**

Drop any `.cheat` file into `~/dotfiles/cheatsheets/`. Format:

```
% tag1, tag2

# Description of what the command does
the_command_or_key_sequence
```

navi picks up new files automatically — no restart needed.

**Current cheat files:**

| File | Contents |
|---|---|
| `cheatsheets/aerospace.cheat` | All AeroSpace key bindings |
| `cheatsheets/nvim.cheat` | Neovim: LSP, Telescope, neo-tree, Copilot |
| `cheatsheets/tmux.cheat` | tmux sessions, panes, windows, copy mode |
