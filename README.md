# dotfiles

AeroSpace + sketchybar + borders configuration.

## What's included

| File/Dir | Symlink target | Description |
|---|---|---|
| `aerospace.toml` | `~/.aerospace.toml` | AeroSpace window manager config |
| `sketchybar/` | `~/.config/sketchybar/` | sketchybar status bar config + plugins |
| `bordersrc` | `~/.config/borders/bordersrc` | JankyBorders window border config |

## Setup on a new Mac

### One-liner (recommended)

```bash
git clone <your-repo-url> ~/dotfiles && ~/dotfiles/install.sh
```

`install.sh` handles everything: Homebrew, dependencies, symlinks, and starting services. Existing configs are backed up as `*.bak` before being replaced.

### Manual steps (if you prefer)

<details>
<summary>Expand manual setup</summary>

#### 1. Install dependencies

```bash
# Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Window manager + status bar + borders
brew install --cask nikitabobko/tap/aerospace
brew install felixkratz/formulae/sketchybar
brew install FelixKratz/formulae/borders

# App font for sketchybar icons
brew tap FelixKratz/formulae
brew install sketchybar-app-font
```

#### 2. Clone this repo

```bash
git clone <your-repo-url> ~/dotfiles
```

#### 3. Create symlinks

```bash
ln -sf ~/dotfiles/aerospace.toml ~/.aerospace.toml
ln -sf ~/dotfiles/sketchybar ~/.config/sketchybar
mkdir -p ~/.config/borders && ln -sf ~/dotfiles/bordersrc ~/.config/borders/bordersrc
```

#### 4. Start services

```bash
brew services start sketchybar
brew services start borders
open -a AeroSpace
```

</details>

### After install

1. Grant Accessibility permissions: System Settings → Privacy & Security → Accessibility → **AeroSpace**
2. Reload AeroSpace config: `alt-shift-;` then `esc`
3. Hide native menu bar so sketchybar takes over: System Settings → Desktop & Dock → Menu Bar → "Automatically hide and show the menu bar" → **Always** (the install script sets this automatically via `defaults write`)

#### If apps don't appear in the permission list

macOS may not list AeroSpace, sketchybar, or borders automatically. Add them manually:

- System Settings → Privacy & Security → Accessibility → click **+**
- Navigate to the Homebrew Cellar and select the binary:

| App | Path |
|---|---|
| AeroSpace | `/opt/homebrew/Caskroom/nikitabobko-aerospace/<version>/AeroSpace.app` |
| sketchybar | `/opt/homebrew/bin/sketchybar` |
| borders | `/opt/homebrew/bin/borders` |

> **Tip:** In the Finder open dialog press `Cmd-Shift-G` and paste the path to jump directly to it.

### Verify

- AeroSpace: `alt-1` through `alt-9` switches workspaces
- sketchybar: visible at top with workspace indicators, battery, wifi, bluetooth
- borders: focused window has blue border, inactive windows dark border

## Key bindings (AeroSpace)

| Binding | Action |
|---|---|
| `alt-h/j/k/l` | Focus window (wraps across monitors) |
| `alt-shift-h/j/k/l` | Move window |
| `alt-1..9` | Switch workspace |
| `alt-shift-1..9` | Move window to workspace |
| `alt-ctrl-↑/↓/←/→` | Move window to another monitor |
| `alt-tab` | Toggle last workspace |
| `alt-shift-tab` | Move workspace to next monitor |
| `alt-ctrl-f` | Toggle float/tile |
| `alt-ctrl-shift-f` | Fullscreen |
| `alt-g` | Open Ghostty |
| `alt-b` | Open Brave Browser |
| `alt-i` | Open IntelliJ IDEA |
| `alt-o` | Open Obsidian |
| `alt-f` | Open Finder |
| `alt-v` | Open VS Code |
| `alt-shift-;` | Service mode (reload config: `esc`) |
