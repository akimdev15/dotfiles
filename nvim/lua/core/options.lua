-- ============================================================================
-- Global Flags
-- ============================================================================
vim.g.copilot_filetypes = { java = false } -- disable Copilot autocomplete for LeetCode Java

-- ============================================================================
-- Line Numbers
-- ============================================================================
vim.opt.number         = true  -- show absolute line number on current line
vim.opt.relativenumber = true  -- show relative numbers on all other lines

-- ============================================================================
-- Mouse & Clipboard
-- ============================================================================
vim.opt.mouse     = 'a'            -- enable mouse in all modes (useful for resizing splits)
vim.opt.clipboard = 'unnamedplus'  -- sync yank/paste with the OS clipboard

-- ============================================================================
-- UI / Display
-- ============================================================================
vim.opt.showmode     = false  -- mode is already shown by the statusline
vim.opt.cmdheight    = 0      -- hide cmdline when idle; expands automatically when typing : or showing messages
vim.opt.cursorline   = true   -- highlight the current line
vim.opt.signcolumn   = 'yes'  -- always show the sign column (prevents layout shift)
vim.opt.scrolloff    = 10     -- keep ≥10 lines visible above/below the cursor
vim.opt.termguicolors = true  -- enable 24-bit RGB colours
vim.opt.list         = true   -- show invisible characters
vim.opt.listchars    = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand   = 'split'  -- live preview of :s substitutions in a split

-- ============================================================================
-- Indentation
-- ============================================================================
vim.opt.breakindent = true   -- wrapped lines continue at the same indent level
vim.opt.expandtab   = true   -- convert <Tab> keystrokes to spaces
vim.opt.shiftwidth  = 2      -- spaces used by >> / << and auto-indent
-- smartindent is the lightweight fallback now that treesitter indent is disabled.
-- It handles the common cases (new lines, closing braces) without walking the syntax tree.
vim.opt.smartindent = true

-- ============================================================================
-- Search
-- ============================================================================
vim.opt.hlsearch   = true  -- highlight all matches after a search
vim.opt.incsearch  = true  -- show matches incrementally as you type
vim.opt.ignorecase = true  -- searches are case-insensitive by default
vim.opt.smartcase  = true  -- override ignorecase when the pattern has uppercase

-- ============================================================================
-- Splits
-- ============================================================================
vim.opt.splitright = true  -- new vertical split opens to the right
vim.opt.splitbelow = true  -- new horizontal split opens below

-- ============================================================================
-- Performance / Responsiveness
-- ============================================================================
vim.opt.updatetime = 400   -- ms before CursorHold fires; 250 is too aggressive on slow LSPs
vim.opt.timeoutlen = 300   -- keep mapped keys responsive without a 1s wait
vim.opt.ttimeoutlen = 10   -- ms to wait for terminal key/mouse escape sequences
vim.opt.synmaxcol  = 240   -- skip syntax/regex highlight past col 240 (minified/log files)
vim.opt.redrawtime = 1500  -- bail on regex highlight after 1.5s instead of 2s default
-- Trim shada writes: !,'500=marks for 500 files, <50=50 lines/reg, s10=10KB/item, h=no hlsearch
vim.opt.shada      = "!,'500,<50,s10,h"

-- ============================================================================
-- Files & Persistence
-- ============================================================================
vim.opt.undofile    = true   -- persist undo history across sessions
vim.opt.swapfile    = false  -- no swap files
vim.opt.backup      = false  -- no backup files
vim.opt.fileencoding = 'utf-8'

-- ============================================================================
-- Completion
-- ============================================================================
vim.opt.completeopt = { 'menu', 'menuone', 'noinsert' }
