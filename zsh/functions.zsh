# ============================================================================
# functions.zsh — shared shell functions. Guard tool-specific ones so they
# don't pollute the function table on machines missing the binary.
# ============================================================================

# Aerospace window fuzzy finder: list windows → fzf → focus selected.
if command -v aerospace >/dev/null && command -v fzf >/dev/null; then
  ff() {
    aerospace list-windows --all | \
      fzf --bind 'enter:execute(aerospace focus --window-id {1})+abort' \
          --height 40% \
          --layout reverse \
          --border rounded \
          --prompt 'window > '
  }
fi
