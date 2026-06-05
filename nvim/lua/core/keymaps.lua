-- ============================================================================
-- Search
-- ============================================================================
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

-- ============================================================================
-- Diagnostics
-- ============================================================================
vim.diagnostic.config({
  float = { border = 'rounded' },
})
vim.keymap.set('n', '[d',        vim.diagnostic.goto_prev,  { desc = 'Previous diagnostic' })
vim.keymap.set('n', ']d',        vim.diagnostic.goto_next,  { desc = 'Next diagnostic' })
vim.keymap.set('n', 'gl',        vim.diagnostic.open_float, { desc = 'Show line diagnostics' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic quickfix' })

-- ============================================================================
-- Terminal
-- ============================================================================
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('t', '<C-q>',      '<C-\\><C-n>', { desc = 'Exit terminal mode (fallback)' })

-- ============================================================================
-- Window Navigation
-- Fallback bindings — vim-tmux-navigator overrides these when inside tmux.
-- ============================================================================
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Focus left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Focus right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Focus lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Focus upper window' })
