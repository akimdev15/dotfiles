-- Enable Lua bytecode cache — must be first line, speeds up all module loads
vim.loader.enable()

-- ============================================================================
-- Leader keys  (must be set before lazy.nvim loads)
-- ============================================================================
vim.g.mapleader      = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

-- ============================================================================
-- Core modules
-- ============================================================================
require('core.options')   -- vim.opt settings
require('core.keymaps')   -- base keymaps (non-plugin)
require('core.autocmds')  -- autocommands

-- ============================================================================
-- Plugin manager — lazy.nvim
-- ============================================================================
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
---@diagnostic disable-next-line: undefined-field
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none', '--branch=stable',
    'https://github.com/folke/lazy.nvim.git', lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- Plugin specs
-- Each file under lua/plugins/ returns a table of lazy.nvim plugin specs.
-- ============================================================================
require('lazy').setup({
  { import = 'plugins.ui' },       -- colorscheme, statusline
  { import = 'plugins.editor' },   -- telescope, treesitter, comments
  { import = 'plugins.lsp' },      -- LSP, Mason, nvim-cmp
  { import = 'plugins.java' },     -- Java LSP via nvim-jdtls
  { import = 'plugins.format' },   -- conform.nvim — format on save
  { import = 'plugins.tools' },    -- neo-tree, tmux-navigator
  { import = 'plugins.git' },      -- gitsigns — gutter signs for uncommitted changes
  { import = 'plugins.leetcode' }, -- LeetCode + Obsidian vault integration
  { import = 'plugins.copilot' }, -- GitHub Copilot ghost-text (comment out to remove)
  { import = 'plugins.lazygit' }, -- Lazygit floating window
  { import = 'plugins.test' },   -- vim-test
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd     = '⌘', config  = '🛠', event   = '📅', ft    = '📂',
      init    = '⚙', keys    = '🗝', plugin  = '🔌', runtime = '💻',
      require = '🌙', source  = '📄', start   = '🚀', task  = '📌',
      lazy    = '💤 ',
    },
  },
  change_detection = { enabled = false, notify = false }, -- skip filewatcher on plugin specs
  performance = {
    cache = { enabled = true },
    reset_packpath = true,
    rtp = {
      -- Disable built-in plugins that are never used — reduces RTP scan on every file open
      disabled_plugins = {
        'gzip', 'matchit', 'matchparen', 'netrwPlugin',
        'tarPlugin', 'tohtml', 'tutor', 'zipPlugin',
        'rplugin', 'spellfile', 'man',
      },
    },
  },
})

-- vim: ts=2 sts=2 sw=2 et
