-- ============================================================================
-- Format on save — conform.nvim
--
-- Per-language formatters. Add or change entries in `by_ft`; install binaries
-- via Mason (`:MasonInstall <name>`) or Homebrew (see init_setup.sh).
--
-- Manual format any time:  :lua require('conform').format()
-- Skip auto-format once:   :w   →  :ConformDisable  /  :ConformEnable
-- ============================================================================

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
        lua              = { 'stylua' },
        python           = { 'ruff_format' },
        java             = { 'google-java-format' },
        sql              = { 'pg_format' },
        go               = { 'goimports', 'golines' },

        -- Prettier covers the JS/TS family and common web formats.
        javascript       = { 'prettier' },
        javascriptreact  = { 'prettier' },
        typescript       = { 'prettier' },
        typescriptreact  = { 'prettier' },
        json             = { 'prettier' },
        jsonc            = { 'prettier' },
        yaml             = { 'prettier' },
        markdown         = { 'prettier' },
        css              = { 'prettier' },
        html             = { 'prettier' },
      },

      formatters = {
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
