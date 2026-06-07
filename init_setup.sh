#!/usr/bin/env bash
set -e

DOTFILES="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "==> Installing dependencies..."

# Homebrew
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null
fi

brew install --cask nikitabobko/tap/aerospace
brew install felixkratz/formulae/sketchybar
brew install FelixKratz/formulae/borders
brew install neovim
brew install tmux
brew install navi
brew install pgformatter   # `pg_format` — SQL formatter for Postgres

# Rust-backed search / format tools — used by telescope and conform.nvim.
# Mason can install some of these too, but Homebrew puts them on $PATH for
# every shell, not only inside nvim.
brew install ripgrep        # `rg` — telescope live_grep backend
brew install fd             # `fd`  — fast find replacement
brew install stylua         # Lua formatter (Rust)
brew install taplo          # TOML formatter (Rust) — used when use_taplo=true

if ! brew list --cask font-sketchybar-app-font &>/dev/null; then
  brew install --cask font-sketchybar-app-font
fi

echo "==> Creating symlinks..."

backup_and_link() {
  local src="$1"
  local dst="$2"

  mkdir -p "$(dirname "$dst")"

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
      echo "  already linked: $dst"
      return
    fi
    echo "  backing up: $dst -> $dst.bak"
    mv "$dst" "$dst.bak"
  fi

  ln -sf "$src" "$dst"
  echo "  linked: $dst -> $src"
}

backup_and_link "$DOTFILES/aerospace/aerospace.toml" "$HOME/.aerospace.toml"
backup_and_link "$DOTFILES/sketchybar"               "$HOME/.config/sketchybar"
backup_and_link "$DOTFILES/borders/bordersrc"        "$HOME/.config/borders/bordersrc"
backup_and_link "$DOTFILES/nvim"                     "$HOME/.config/nvim"
backup_and_link "$DOTFILES/tmux/tmux.conf"           "$HOME/.tmux.conf"
backup_and_link "$DOTFILES/navi"                     "$HOME/.config/navi"

echo "==> Starting services..."
brew services list | grep -q "sketchybar.*started" \
  && echo "  sketchybar already running" \
  || brew services start sketchybar
brew services list | grep -q "borders.*started" \
  && echo "  borders already running" \
  || brew services start borders
open -a AeroSpace 2>/dev/null || true

echo ""
echo "Done! Next steps:"
echo "  1. System Settings → Desktop & Dock → Menu Bar"
echo "     → 'Automatically hide and show the menu bar' → Always"
echo "  2. Grant Accessibility: System Settings → Privacy & Security → Accessibility → AeroSpace"
echo "  3. Reload AeroSpace: Alt-Shift-; then Esc"
echo "  4. Open nvim — plugins auto-install via lazy.nvim,"
echo "     LSP servers + formatters auto-install via mason-tool-installer"
echo "  5. Authorize GitHub Copilot: :Copilot auth"
echo ""
echo "Cheatsheet popup: prefix+? (inside tmux)"
