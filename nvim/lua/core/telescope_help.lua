local M = {}

local lines = {
  'Telescope Shortcuts',
  '',
  'Files and buffers',
  '  <Space> f f    Find files',
  '  <Space> f b    Find open buffers',
  '  <Space><Space> Find open buffers',
  '  <Space> s .    Recent files',
  '  <Space> s n    Search Neovim config files',
  '',
  'Search',
  '  <Space> /      Fuzzy search current file',
  '  <Space> f g    Live grep project',
  '  <Space> l g    Live grep current working directory',
  '  <Space> s /    Live grep open files only',
  '  <Space> s w    Search word under cursor',
  '',
  'Code navigation',
  '  <Space> d s    Current file symbols/functions',
  '  <Space> f r    Find references',
  '  <Space> s d    Search diagnostics',
  '  <Space> s k    Search keymaps',
  '  <Space> s s    Search Telescope pickers',
  '',
  'Inside Telescope',
  '  <C-j> / <C-k>  Move selection down/up',
  '  <Enter>       Open selected item',
  '  <Esc> / <C-c> Close popup',
  '  dd            Delete selected buffer in buffer picker',
  '',
  'Tip: use <Space> d s for the file outline popup, then type to filter.',
}

function M.show()
  local width = 58
  local height = #lines
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = 'wipe'

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' Telescope Help ',
    title_pos = 'center',
  })

  vim.wo[win].wrap = false
  vim.wo[win].cursorline = true

  local close = function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  vim.keymap.set('n', 'q', close, { buffer = buf, nowait = true, desc = 'Close help popup' })
  vim.keymap.set('n', '<Esc>', close, { buffer = buf, nowait = true, desc = 'Close help popup' })
end

return M
