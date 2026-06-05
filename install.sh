#!/usr/bin/env bash
set -e

DOTFILES="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "==> Installing dependencies..."

# Homebrew
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add brew to PATH for Apple Silicon
  eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null
fi

brew install --cask nikitabobko/tap/aerospace
brew install felixkratz/formulae/sketchybar
brew install FelixKratz/formulae/borders
brew install neovim
brew install tmux

# sketchybar app font for icons
if ! fc-list 2>/dev/null | grep -qi "sketchybar"; then
  brew tap FelixKratz/formulae
  brew install sketchybar-app-font
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

backup_and_link "$DOTFILES/aerospace.toml"     "$HOME/.aerospace.toml"
backup_and_link "$DOTFILES/sketchybar"          "$HOME/.config/sketchybar"
backup_and_link "$DOTFILES/bordersrc"           "$HOME/.config/borders/bordersrc"
backup_and_link "$DOTFILES/nvim"                "$HOME/.config/nvim"
backup_and_link "$DOTFILES/tmux.conf"           "$HOME/.tmux.conf"

echo "==> Hiding native macOS menu bar (sketchybar replaces it)..."
defaults write com.apple.dock autohide-menubar -bool true
killall Dock

echo "==> Starting services..."

brew services start sketchybar
brew services start borders
open -a AeroSpace 2>/dev/null || true

echo ""
echo "Done. Grant Accessibility permissions if prompted:"
echo "  System Settings → Privacy & Security → Accessibility → AeroSpace"
echo ""
echo "Reload AeroSpace config: alt-shift-; then esc"
