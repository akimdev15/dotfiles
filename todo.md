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

Tiny standalone modules from one author. Each loads independently, no shared core. Add only the ones you actually want.

### `mini.surround` — manipulate surrounding pairs (`"`, `(`, `<tag>`, ...)

| Key | Action |
|---|---|
| `sa{motion}{char}` | **s**urround **a**dd. e.g. `saiw"` → wrap inner word in `"`. |
| `sd{char}` | **s**urround **d**elete. e.g. `sd(` → strip parens. |
| `sr{from}{to}` | **s**urround **r**eplace. e.g. `sr'"` → `'foo'` → `"foo"`. |
| `sf{char}` / `sF{char}` | find next / prev surrounding char. |
| `sh{char}` | highlight matching surrounding. |

### `mini.pairs` — auto-close brackets/quotes

- Type `(` → `()` with cursor inside. Same for `[`, `{`, `"`, `'`, backticks.
- `<BS>` inside empty pair removes both halves.
- `<CR>` inside `{` opens a properly-indented block.
- No new shortcuts — it just makes the keys you already press smarter.

### `mini.comment` — comment toggling (Comment.nvim replacement)

| Key | Action |
|---|---|
| `gcc` | toggle current line comment |
| `gc{motion}` | toggle comment over motion (e.g. `gcap` = paragraph) |
| `gc` (visual) | toggle comment over selection |

Same keys as current `Comment.nvim`, so swap is invisible to muscle memory. Win: 1 plugin replaced with ~50 LoC from a module you'll already have for surround/pairs.

### `mini.indentscope` — animated indent-scope guide

- Vertical line marks the indent block your cursor is inside (function body, if-block, etc).
- Motions:

| Key | Action |
|---|---|
| `[i` / `]i` | jump to top / bottom of current scope |
| `ii` / `ai` | text-object: **i**nner / **a**round indent scope (use with `d`, `c`, `y`, `v`) |

### `mini.ai` — better text objects

Extends `i` / `a` text-objects to many more targets.

| Key | Action |
|---|---|
| `daf` | delete a function call (`foo(bar)`) |
| `cif` | change inside function args |
| `dia` | delete inner argument in a call list |
| `vat` | select around HTML/XML tag |

### `mini.move` — move lines/selections with `Alt-h/j/k/l`

Like the `:m` command but on a key. Works in normal and visual mode.

### Why deferred

- Would replace `Comment.nvim` (same keys — no behavior change there).
- `surround`/`pairs`/`ai`/`move` add *new* keymaps. User has to learn them. That's a behavior change.
- Each module is ~5ms of startup at most. Combined zero-impact.

### Path

```lua
-- nvim/lua/plugins/mini.lua
return {
  { 'echasnovski/mini.surround',    event = 'VeryLazy', opts = {} },
  { 'echasnovski/mini.pairs',       event = 'InsertEnter', opts = {} },
  { 'echasnovski/mini.ai',          event = 'VeryLazy', opts = {} },
  { 'echasnovski/mini.move',        event = 'VeryLazy', opts = {} },
  { 'echasnovski/mini.indentscope', event = { 'BufReadPre', 'BufNewFile' }, opts = {} },
  -- and drop Comment.nvim once mini.comment is in:
  -- { 'echasnovski/mini.comment',   event = 'VeryLazy', opts = {} },
}
```

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
