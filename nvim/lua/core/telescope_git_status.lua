-- ============================================================================
-- Prettier entry_maker for `Telescope git_status` (<leader>gs).
--
-- The stock entry_maker renders two blank-looking columns (a bare "~"/"?"
-- character with no highlight group defined by our colorscheme) followed by
-- the plain file path — effectively black-and-white. This version adds:
--   • Nerd Font glyphs colored per status (add/change/delete/untracked),
--     reusing the same hues as the `:diff`/gitsigns highlights so it's
--     visually consistent with the rest of the editor.
--   • A filetype devicon (via mini.icons' nvim-web-devicons mock) so files
--     are recognizable at a glance, same as every other file picker.
-- ============================================================================

local M = {}

local status_icons = {
  A = { icon = '', hl = 'TelescopeResultsDiffAdd' },
  U = { icon = '', hl = 'TelescopeResultsDiffAdd' },
  M = { icon = '', hl = 'TelescopeResultsDiffChange' },
  C = { icon = '', hl = 'TelescopeResultsDiffChange' },
  R = { icon = '', hl = 'TelescopeResultsDiffChange' },
  D = { icon = '', hl = 'TelescopeResultsDiffDelete' },
  ['?'] = { icon = '', hl = 'TelescopeResultsDiffUntracked' },
}

-- Returns the concrete `function(line) -> entry` that telescope's git_status
-- picker expects for its `entry_maker` option. Unlike telescope's own
-- generator, this doesn't need to be re-created per invocation with
-- call-specific opts (cwd, path_display, ...) — it reads those live from
-- telescope's resolved config / vim's cwd instead, so a single instance can
-- be built once at setup time and reused for every `<leader>gs` press.
function M.entry_maker(opts)
  opts = opts or {}

  local entry_display = require('telescope.pickers.entry_display')
  local utils = require('telescope.utils')
  local Path = require('plenary.path')
  local devicons_ok, devicons = pcall(require, 'nvim-web-devicons')

  local displayer = entry_display.create({
    separator = ' ',
    items = {
      { width = 2 }, -- status glyph
      { width = 2 }, -- filetype devicon
      { remaining = true },
    },
  })

  local make_display = function(entry)
    local x = entry.status:sub(1, 1)
    local y = entry.status:sub(-1)
    local status = status_icons[x] or status_icons[y] or {}

    local icon, icon_hl = '', ''
    if devicons_ok then
      local filename = vim.fn.fnamemodify(entry.value, ':t')
      icon, icon_hl = devicons.get_icon(filename, filename:match('%.([^.]+)$'), { default = true })
      icon = icon or ''
    end

    return displayer({
      { status.icon or ' ', status.hl },
      { icon, icon_hl },
      utils.transform_path(opts, entry.path),
    })
  end

  return function(entry)
    if entry == '' then
      return nil
    end

    local mod, file = entry:match('^(..) (.+)$')
    if not mod then
      return nil
    end

    local cwd = opts.cwd or vim.loop.cwd()

    return setmetatable({
      value = file,
      status = mod,
      ordinal = entry,
      display = make_display,
      path = Path:new({ cwd, file }):absolute(),
    }, opts)
  end
end

return M
