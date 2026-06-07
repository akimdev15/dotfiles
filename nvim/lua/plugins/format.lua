-- ============================================================================
-- Format on save — conform.nvim
--
-- Per-language formatters. Add or change entries in `by_ft`; install binaries
-- via Mason (`:MasonInstall <name>`) or Homebrew (see init_setup.sh).
--
-- Manual format any time:  :lua require('conform').format()
-- Skip auto-format once:   :w   →  :ConformDisable  /  :ConformEnable
--
-- Tool selection is driven by lua/core/config.lua flags. See that file to
-- toggle Rust / daemon formatters on or off — output stays identical for
-- defaulted-on flags (prettierd, taplo).
-- ============================================================================

local cfg = require('core.config')

-- prefer_rust = false zeroes every use_* flag in one place.
local function on(flag)
  return cfg.prefer_rust and cfg[flag]
end

-- Identical-output: prettier daemon. Drop-in.
local prettier   = on('use_prettierd') and 'prettierd' or 'prettier'
-- Output-differing: biome replaces prettier across the JS/JSON family.
local js_fmt     = on('use_biome')  and { 'biome' } or { prettier }
local json_fmt   = on('use_biome')  and { 'biome' }
                or on('use_dprint') and { 'dprint' }
                or { prettier }
local md_fmt     = on('use_dprint') and { 'dprint' } or { prettier }
local yaml_fmt   = on('use_dprint') and { 'dprint' } or { prettier }
local toml_fmt   = on('use_taplo')  and { 'taplo' }  or nil
local web_fmt    = { prettier } -- css/html stay prettier; biome doesn't cover them

return {
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd   = { 'ConformInfo' },
    opts  = {
      notify_on_error = false,

      format_on_save = function(bufnr)
        -- Toggle off with :let g:disable_autoformat = 1  (global)
        --             or :let b:disable_autoformat = 1  (buffer)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 1500, lsp_format = 'fallback' }
      end,

      formatters_by_ft = {
        lua              = { 'stylua' },           -- Rust
        python           = { 'ruff_format' },      -- Rust
        java             = { 'google-java-format' },
        sql              = { 'pg_format' },
        go               = { 'goimports', 'golines' },
        toml             = toml_fmt,               -- Rust (taplo) when enabled

        javascript       = js_fmt,
        javascriptreact  = js_fmt,
        typescript       = js_fmt,
        typescriptreact  = js_fmt,
        json             = json_fmt,
        jsonc            = json_fmt,
        yaml             = yaml_fmt,
        markdown         = md_fmt,
        css              = web_fmt,
        html             = web_fmt,
      },

      formatters = {
        ['google-java-format'] = {
          prepend_args = { '--aosp' },
        },
        pg_format = {
          command = 'pg_format',
          args    = { '-' },     -- read stdin, write stdout
          stdin   = true,
        },
      },
    },
    init = function()
      vim.api.nvim_create_user_command('FormatDisable', function(args)
        if args.bang then
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, { desc = 'Disable autoformat (bang = buffer only)', bang = true })

      vim.api.nvim_create_user_command('FormatEnable', function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, { desc = 'Re-enable autoformat' })
    end,
  },
}
