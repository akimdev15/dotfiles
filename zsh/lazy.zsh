# ============================================================================
# lazy.zsh — defer expensive tool initialization until first use.
# Pattern: define a no-op stub function that on first call sources the real
# init and re-invokes itself with the original args.
# Each block is guarded so it's a no-op on machines without the tool.
# ============================================================================

# ── NVM (Node Version Manager) ───────────────────────────────────────────────
# Cold sourcing nvm.sh costs ~200ms. Lazy stubs cost ~0ms until you use Node.
if [ -d "$HOME/.nvm" ] || [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
  _load_nvm() {
    unset -f nvm node npm npx
    local nvm_sh="/opt/homebrew/opt/nvm/nvm.sh"
    [ -s "$nvm_sh" ] && source "$nvm_sh"
  }
  nvm()  { _load_nvm; nvm  "$@"; }
  node() { _load_nvm; node "$@"; }
  npm()  { _load_nvm; npm  "$@"; }
  npx()  { _load_nvm; npx  "$@"; }
fi

# ── Bun completion ───────────────────────────────────────────────────────────
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# ── uv (Astral Python installer) ─────────────────────────────────────────────
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
