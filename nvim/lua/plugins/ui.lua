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
  -- Statusline
  -- --------------------------------------------------------------------------
  {
    'vim-airline/vim-airline',
    event = 'VimEnter',
  },

}
