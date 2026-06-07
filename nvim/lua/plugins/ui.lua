-- ============================================================================
-- UI: colorscheme and statusline
-- ============================================================================
return {

  -- --------------------------------------------------------------------------
  -- Dracula colorscheme
  -- --------------------------------------------------------------------------
  {
    'Mofiqul/dracula.nvim',
    priority = 1000,
    config = function()
      require('dracula').setup({
        transparent_bg = true,
        italic_comment = true,
      })
      vim.cmd.colorscheme('dracula')
    end,
  },

  -- --------------------------------------------------------------------------
  -- Cyberdream colorscheme (commented out)
  -- --------------------------------------------------------------------------
  -- {
  --   'scottmckendry/cyberdream.nvim',
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     require('cyberdream').setup({
  --       transparent = true,
  --       italic_comments = true,
  --       hide_fillchars = true,
  --       borderless_pickers = true,
  --       terminal_colors = true,
  --       extensions = {
  --         telescope = true,
  --         notify = true,
  --         mini = true,
  --         treesitter = true,
  --         treesittercontext = true,
  --         whichkey = true,
  --         lazy = true,
  --         cmp = true,
  --         gitsigns = true,
  --         indentblankline = true,
  --       },
  --     })
  --     vim.cmd.colorscheme('cyberdream')
  --   end,
  -- },

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
          theme                = 'dracula',
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
        tabline = {
          lualine_a = {
            {
              'buffers',
              mode             = 2, -- show buffer number + name
              show_modified_status = true,
              symbols          = { modified = ' ●', alternate_file = '#', directory = '' },
            },
          },
          lualine_z = {
            { 'tabs', mode = 1 },
          },
        },
        extensions = { 'neo-tree', 'lazy', 'mason', 'quickfix', 'fugitive' },
      })
    end,
  },

}
