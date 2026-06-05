-- ============================================================================
-- GitHub Copilot — ghost-text inline suggestions
--
-- To DISABLE: comment out `{ import = 'plugins.copilot' }` in init.lua
-- To RE-ENABLE: uncomment it and run :Lazy sync
-- ============================================================================

-- Set to false to disable ghost text without removing the plugin entirely.
-- Useful when you want Copilot auth/panel available but not inline suggestions.
local GHOST_TEXT_ENABLED = true

return {
  {
    'zbirenbaum/copilot.lua',
    -- Load on insert so it doesn't add to the cold-start path
    event = 'InsertEnter',
    cmd   = 'Copilot',
    opts  = {
      -- ── Inline ghost-text suggestions ────────────────────────────────────
      suggestion = {
        enabled    = GHOST_TEXT_ENABLED,
        auto_trigger = true,     -- show suggestion automatically as you type
        hide_during_completion = true, -- hide when nvim-cmp menu is open
        debounce   = 75,         -- ms to wait before requesting a suggestion
        keymap     = {
          accept        = '<C-f>',  -- Ctrl-f → accept whole suggestion
          accept_word   = '<M-w>',  -- Alt-w  → accept one word
          accept_line   = '<M-j>',  -- Alt-j  → accept one line
          next          = '<M-]>',  -- Alt-]  → next suggestion
          prev          = '<M-[>',  -- Alt-[  → prev suggestion
          dismiss       = '<C-]>',  -- Ctrl-] → dismiss
        },
      },
      -- ── Multi-suggestion panel (like Copilot panel in VS Code) ───────────
      panel = {
        enabled  = true,
        auto_refresh = false,
        keymap   = {
          jump_prev = '[[',
          jump_next = ']]',
          accept    = '<CR>',
          refresh   = 'gr',
          open      = '<M-CR>',   -- Alt-Enter → open panel
        },
        layout = {
          position = 'bottom',
          ratio    = 0.4,
        },
      },
      -- Filetypes where Copilot is active. Add/remove as needed.
      filetypes = {
        ['*']      = true,   -- enable everywhere by default
        -- ['yaml']   = false,  -- example: disable for yaml
        -- ['markdown'] = false,
      },
    },
    keys = {
      -- Manual toggle commands available outside insert mode
      { '<leader>ct', '<cmd>Copilot toggle<CR>',         desc = '[C]opilot [T]oggle' },
      { '<leader>cs', '<cmd>Copilot status<CR>',         desc = '[C]opilot [S]tatus' },
      { '<leader>cp', '<cmd>Copilot panel<CR>',          desc = '[C]opilot [P]anel' },
      { '<leader>ca', '<cmd>Copilot auth<CR>',           desc = '[C]opilot [A]uth' },
      { '<leader>ce', '<cmd>Copilot enable<CR>',         desc = '[C]opilot [E]nable' },
      { '<leader>cd', '<cmd>Copilot disable<CR>',        desc = '[C]opilot [D]isable' },
    },
  },
}
