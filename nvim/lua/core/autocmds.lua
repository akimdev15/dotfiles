-- ============================================================================
-- Explicit filetype mappings for files Neovim misses
-- ============================================================================
vim.filetype.add({
  extension = {
    ts  = 'typescript',
    tsx = 'typescriptreact',
  },
})

vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
  group   = vim.api.nvim_create_augroup('typescript-filetype-fallback', { clear = true }),
  pattern = { '*.ts', '*.tsx' },
  callback = function(ev)
    if vim.bo[ev.buf].filetype ~= '' then return end

    local ext = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(ev.buf), ':e')
    vim.bo[ev.buf].filetype = ext == 'tsx' and 'typescriptreact' or 'typescript'
  end,
})

-- Start Neovim's built-in treesitter highlighter early enough for the first
-- opened file. Deferring by one tick lets the file render before parsing.
local treesitter_group = vim.api.nvim_create_augroup('core-treesitter-highlight', { clear = true })

local function start_treesitter(buf)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  if vim.bo[buf].buftype ~= '' then return end
  if vim.bo[buf].filetype == '' then return end
  if vim.treesitter.highlighter.active[buf] then return end

  pcall(vim.treesitter.start, buf)
end

vim.api.nvim_create_autocmd('FileType', {
  group = treesitter_group,
  callback = function(ev)
    vim.defer_fn(function()
      start_treesitter(ev.buf)
    end, 1)
  end,
})

-- ============================================================================
-- UI: Ensure visible borders for floating windows
-- ============================================================================
vim.api.nvim_create_autocmd('ColorScheme', {
  desc  = 'Ensure FloatBorder is visible after colorscheme changes',
  group = vim.api.nvim_create_augroup('visible-borders', { clear = true }),
  callback = function()
    -- Set the border color to Dracula's purple for high visibility
    vim.api.nvim_set_hl(0, 'FloatBorder', { fg = '#bd93f9' })
  end,
})

-- ============================================================================
-- UI: High-contrast Visual-mode selection
-- Carbonfox default selection bg is hard to spot on the near-black background.
-- Override to a brighter purple-blue so highlights pop instantly.
-- Swap the hex below to taste:
--   #44475a  Dracula default        (subtle)
--   #3e4d63  steel blue             (medium)
--   #4d5277  brighter purple-blue   (current — high contrast)
--   #6272a4  Dracula comment        (very high contrast)
-- ============================================================================
vim.api.nvim_create_autocmd('ColorScheme', {
  desc  = 'High-contrast Visual selection',
  group = vim.api.nvim_create_augroup('visible-visual', { clear = true }),
  callback = function()
    vim.api.nvim_set_hl(0, 'Visual', { bg = '#4d5277', bold = true })
  end,
})

-- ============================================================================
-- Auto-reload files changed outside nvim
-- ============================================================================
vim.o.autoread = true
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter' }, {
  group    = vim.api.nvim_create_augroup('auto-reload', { clear = true }),
  command  = 'checktime',
})

-- ============================================================================
-- Highlight on Yank
-- ============================================================================
vim.api.nvim_create_autocmd('TextYankPost', {
  desc  = 'Briefly highlight text after yanking',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- ============================================================================
-- Java: 4-space indent
-- ============================================================================
vim.api.nvim_create_autocmd('FileType', {
  pattern  = 'java',
  group    = vim.api.nvim_create_augroup('java-indent', { clear = true }),
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop    = 4
  end,
})

-- ============================================================================
-- Java: Run main() with <F5>
-- Finds the Maven root via pom.xml and runs: ./mvnw compile exec:java
-- ============================================================================
vim.api.nvim_create_autocmd('FileType', {
  pattern  = 'java',
  callback = function(ev)
    vim.keymap.set('n', '<F5>', function()
      local path  = vim.fn.expand('%:p')
      local class = path:match('src/main/java/(.+)%.java$')
      if not class then
        vim.notify('Not inside src/main/java/', vim.log.levels.WARN)
        return
      end
      class = class:gsub('/', '.')

      local pom = vim.fn.findfile('pom.xml', vim.fn.expand('%:p:h') .. ';')
      if pom == '' then
        vim.notify('pom.xml not found', vim.log.levels.WARN)
        return
      end

      local root = vim.fn.fnamemodify(pom, ':h')
      vim.cmd('write')
      vim.cmd('botright 15split | terminal cd ' .. root
        .. ' && ./mvnw -q compile exec:java -Dexec.mainClass=' .. class)
      vim.cmd('startinsert')
    end, { buffer = ev.buf, desc = 'Run Java main()' })
  end,
})
