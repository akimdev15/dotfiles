-- ============================================================================
-- UI: colorscheme and statusline
-- ============================================================================
return {

  -- --------------------------------------------------------------------------
  -- mini.icons — faster devicons (cached lookups, ~10× faster).
  -- Mocks nvim-web-devicons so neo-tree/lualine/telescope keep their visuals
  -- with zero config change. Loaded early (priority > colorscheme) so the
  -- mock is in place before any consumer plugin reads icons.
  -- --------------------------------------------------------------------------
  {
    'echasnovski/mini.icons',
    lazy     = false,
    priority = 1100,
    config = function()
      require('mini.icons').setup()
      MiniIcons.mock_nvim_web_devicons()
    end,
  },

  -- --------------------------------------------------------------------------
  -- Nightfox (carbonfox) colorscheme
  -- --------------------------------------------------------------------------
  {
    'EdenEast/nightfox.nvim',
    priority = 1000,
    config = function()
      require('nightfox').setup({
        options = {
          transparent = false,
          terminal_colors = true,
          styles = {
            comments = 'italic',
          },
        },
      })
      vim.cmd.colorscheme('carbonfox')

      -- Telescope's git_status picker (<leader>gs) ships with no highlights
      -- for its add/change/delete/untracked columns, so carbonfox renders
      -- them as plain white text. Borrow the same hues carbonfox already
      -- uses for `:diff`/gitsigns so the left-hand file list stays legible
      -- and consistent with the rest of the editor.
      local function fg_of(group, fallback)
        local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
        return (ok and hl and hl.fg) or fallback
      end

      local function set_git_status_highlights()
        vim.api.nvim_set_hl(0, 'TelescopeResultsDiffAdd',
          { fg = fg_of('diffAdded', 0x25be6a), bold = true })
        vim.api.nvim_set_hl(0, 'TelescopeResultsDiffChange',
          { fg = fg_of('diffChanged', 0x08bdba), bold = true })
        vim.api.nvim_set_hl(0, 'TelescopeResultsDiffDelete',
          { fg = fg_of('diffRemoved', 0xee5396), bold = true })
        vim.api.nvim_set_hl(0, 'TelescopeResultsDiffUntracked',
          { fg = fg_of('diffFile', 0x78a9ff), bold = true })
      end

      set_git_status_highlights()
      vim.api.nvim_create_autocmd('ColorScheme', { callback = set_git_status_highlights })
    end,
  },

  -- --------------------------------------------------------------------------
  -- Statusline — lualine.nvim
  --
  -- Single statusline (`globalstatus`) shared by every split — one render pass
  -- per refresh instead of N. Tabline shows open buffers + tabs.
  --
  -- Sections (left → right):
  --   A  mode                                          (NORMAL / INSERT / …)
  --   B  git branch + diff stats                       (+adds ~mods -dels)
  --   C  filename (relative) + macro-recording indicator
  --   X  diagnostics + copilot + active LSP + filetype
  --   Y  encoding + progress %
  --   Z  cursor location (line:col)
  -- --------------------------------------------------------------------------
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      -- ── Custom components ─────────────────────────────────────────────────
      local function macro_recording()
        local reg = vim.fn.reg_recording()
        if reg == '' then return '' end
        return ' recording @' .. reg
      end

      local function copilot_status()
        local ok, client = pcall(require, 'copilot.client')
        if not ok then return '' end
        if client.is_disabled() then return ' ' end -- disabled icon
        return ' '                                  -- enabled icon
      end

      local function lsp_clients()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients == 0 then return '' end
        local names = {}
        for _, c in ipairs(clients) do
          table.insert(names, c.name)
        end
        return ' ' .. table.concat(names, ',')
      end

      local function search_count()
        if vim.v.hlsearch == 0 then return '' end
        local ok, result = pcall(vim.fn.searchcount, { maxcount = 999, timeout = 50 })
        if not ok or not result or result.total == 0 then return '' end
        return string.format(' %d/%d', result.current, result.total)
      end

      require('lualine').setup({
        options = {
          theme                = 'carbonfox',
          icons_enabled        = true,
          globalstatus         = true,                              -- single shared statusline
          component_separators = { left = '│', right = '│' },
          section_separators   = { left = '', right = '' },
          disabled_filetypes   = {
            statusline = { 'neo-tree', 'alpha', 'dashboard', 'TelescopePrompt' },
          },
          refresh = { statusline = 250, tabline = 500, winbar = 500 },
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = {
            'branch',
            { 'diff', symbols = { added = ' ', modified = ' ', removed = ' ' } },
          },
          lualine_c = {
            {
              'filename',
              path    = 1,  -- relative path
              symbols = { modified = ' ●', readonly = ' ', unnamed = '[No Name]' },
            },
            { search_count,    color = { fg = '#f1fa8c' } },
            { macro_recording, color = { fg = '#ff5555', gui = 'bold' } },
          },
          lualine_x = {
            {
              'diagnostics',
              sources = { 'nvim_diagnostic' },
              symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
            },
            { copilot_status, color = { fg = '#50fa7b' } },
            { lsp_clients,    color = { fg = '#8be9fd' } },
            'filetype',
          },
          lualine_y = { 'encoding', 'progress' },
          lualine_z = { 'location' },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { 'filename' },
          lualine_x = { 'location' },
          lualine_y = {},
          lualine_z = {},
        },
        extensions = { 'neo-tree', 'lazy', 'mason', 'quickfix', 'fugitive' },
      })
    end,
  },

}
