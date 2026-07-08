local M = {}

local lines = {
  'Telescope Shortcuts',
  '',
  'Files and buffers',
  '  <Space> f f    Find files (tracked, respects .gitignore)',
  '  <Space> f a    Find ALL files — bypasses .gitignore, so it also',
  '                 catches new/untracked files that f f cannot see',
  '  <Space> f b    Find open buffers',
  '  <Space><Space> Find open buffers',
  '  <Space> s .    Recent files',
  '  <Space> s n    Search Neovim config files',
  '',
  'Git — Telescope pickers',
  '  <Space> g s    List changed files; move selection to preview each',
  '                 file\'s diff on the right, <Enter> opens that file',
  '  <Space> g g    Open LazyGit — full TUI for staging, committing,',
  '                 branches; best for reviewing large/complex diffs',
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
  '  <C-u> / <C-d>  Scroll preview up/down (for long diffs/files)',
  '  <Enter>       Open selected item',
  '  <Esc> / <C-c> Close popup',
  '  dd            Delete selected buffer in buffer picker',
  '',
  'Git gutter (gitsigns — sign column marks added/changed/deleted lines)',
  '  ]c / [c        Jump cursor to the next / previous changed hunk',
  '  <Space> h p    Preview the hunk under the cursor in a floating',
  '                 popup, without leaving your place in the file',
  '  <Space> h s    Stage the hunk under the cursor (visual mode:',
  '                 stage only the selected lines) — like git add -p',
  '  <Space> h r    Reset (discard) the hunk under the cursor back',
  '                 to the last commit (visual mode: selected lines)',
  '  <Space> h S    Stage the whole current buffer',
  '  <Space> h R    Reset (discard) all changes in current buffer',
  '  <Space> h b    Show a full git blame popup for the current line',
  '  <Space> g b    Toggle inline blame (author/date at end of line)',
  '  i h            Hunk text object, e.g. dih / yih / vih to',
  '                 delete / yank / select the hunk under the cursor',
  '',
  'Tip: use <Space> d s for the file outline popup, then type to filter.',
}

function M.show()
  local width = 0
  for _, line in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end
  width = math.min(width + 2, vim.o.columns - 4)
  -- Clamp to the terminal size; the buffer still scrolls with j/k if the
  -- content is taller than the window (small terminal / tmux pane).
  local height = math.min(#lines, vim.o.lines - 4)
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
