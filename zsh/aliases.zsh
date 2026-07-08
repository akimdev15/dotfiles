# ============================================================================
# aliases.zsh — shared aliases. Guard tool-specific ones behind `command -v`
# so they silently disappear on machines that don't have the tool.
# Machine-specific aliases (paths, work tools, secrets) belong in
# ~/.zshrc.local, not here.
# ============================================================================

# Editor fuzzy-open: fd → fzf-tmux → nvim.
if command -v fd >/dev/null && command -v fzf-tmux >/dev/null; then
  alias v='fd --type f --hidden --exclude .git | fzf-tmux -p --reverse | xargs nvim'
fi

# ── Git / Docker TUIs ─────────────────────────────────────────────────────────
command -v lazygit    >/dev/null && alias lg='lazygit'
command -v lazydocker >/dev/null && alias ld='lazydocker'
