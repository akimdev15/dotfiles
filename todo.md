# Dotfiles — Future Upgrades

Optimizations deferred because they would change keybindings, look, or output. Each one is opt-in: enable the relevant flag in `nvim/lua/core/config.lua` (or the plugin spec) when you are ready to accept the behavior change.

## Drop-in speed wins (already wired, just flip the flag)

| Change | Flag | Trade-off |
|---|---|---|
| `prettier` → `prettierd` (daemon, identical output) | `use_prettierd` (default **on**) | none — same output, ~10× faster |
| Add `taplo` for TOML | `use_taplo` (default **on**) | none — fills a gap |
| `prettier` → `biome` for JS/TS/JSON | `use_biome` | small style differences (semicolons, quote rules) |
| `prettier` → `dprint` for JSON/MD/YAML | `use_dprint` | small style differences |

## Completion engine — `nvim-cmp` → `blink.cmp`

- Rust-backed fuzzy matcher, ~3-5× faster menu render.
- Why deferred: insert-mode keymaps need re-binding. Current `<C-j>`/`<C-k>`/`<C-y>` map cleanly but snippet jump (`<C-l>`/`<C-h>`) plumbing differs.
- Path: add `Saghen/blink.cmp`, port the keymap table, swap `cmp_nvim_lsp` capabilities → `blink.cmp.get_lsp_capabilities()`.

## Statusline — `vim-airline` → `lualine.nvim`

- Pure Lua, no vimscript boot cost, ~50-100ms startup win.
- Why deferred: visual layout differs slightly; airline themes don't map 1:1.
- Path: add `nvim-lualine/lualine.nvim` with Dracula theme, remove airline.

## Fuzzy finder — `telescope.nvim` → `fzf-lua`

- Uses native `fzf` binary directly, no Lua filtering hot loop. Faster previews on big repos.
- Why deferred: picker UX and `:Telescope` subcommands disappear; many keymaps would need re-wiring.
- Path: install `ibhagwan/fzf-lua`, port the `<leader>s*` / `<leader>f*` table.

## File explorer — `neo-tree` → `oil.nvim`

- Edit the filesystem as a buffer. Insanely fast — no tree refresh, no nested scans.
- Why deferred: completely different mental model (no sidebar / float tree).
- Path: install `stevearc/oil.nvim`, drop neo-tree.

## "kitchen sink" — `folke/snacks.nvim`

- Replaces a stack of plugins (dashboard, notifier, scratch, terminal, lazygit popup, picker) with one shared, faster set.
- Why deferred: large surface change; would replace `lazygit.nvim` popup, possibly part of telescope.

## Mini family — `echasnovski/mini.*`

- `mini.comment`, `mini.surround`, `mini.pairs`, `mini.indentscope` — all tiny, no startup hit.
- Why deferred: would replace `Comment.nvim`; surround/pairs aren't installed yet but adding them is a behavior change.

## Treesitter — pin parsers ahead of `:TSUpdate`

- Currently `nvim-treesitter` is on the `main` branch with auto-install on first open of each filetype, which blocks UI briefly the first time.
- Path: add an explicit parser list and prebuild via `:TSInstallSync`.

## tmux

- `tmux-plugins/tmux-resurrect` runs on every session save — can swap for `tmux-continuum` (auto-restore) if desired.
- Consider `omerxx/tmux-sessionx` (fzf-based session picker) — replaces the scratch popup with a session manager.

## sketchybar plugins

- Several shell scripts spawn ≥3 subshells per tick (`pgrep | awk | sed`). Rewriting in a single `awk`/`jq` call cuts wakeups.
- Bigger win: rewrite the heavier ones (`cpu_mem`, `media`) in Rust as static binaries. Loads once, runs in microseconds. See `https://github.com/FelixKratz/sketchybar` event_provider examples.

## Aerospace

- TOML config — no perf knob to turn. Already optimal.

## Shell

- No `~/.zshrc` in dotfiles. If shell startup feels slow: add `zinit` or move plugins to `znap`/`sheldon` (Rust). Worth a separate audit.

## Rust toolchain coverage gap

- SQL: `pg_format` is Perl. No mature Rust SQL formatter today. `sqlfluff` is Python — slower than `pg_format`. Stay put.
- Markdown lint: `markdownlint-cli` is Node. `dprint` covers formatting; no Rust linter equivalent yet.
