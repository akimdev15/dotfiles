-- ============================================================================
-- Editor: file finding, syntax, navigation, comments
-- ============================================================================
return {

  -- --------------------------------------------------------------------------
  -- Telescope — fuzzy finder for files, LSP, grep, and more
  -- --------------------------------------------------------------------------
  {
    'nvim-telescope/telescope.nvim',
    cmd    = 'Telescope',
    branch = '0.1.x',
    keys   = {
      { '<leader>sh', '<cmd>Telescope help_tags<cr>',    desc = '[S]earch [H]elp' },
      { '<leader>sk', '<cmd>Telescope keymaps<cr>',      desc = '[S]earch [K]eymaps' },
      { '<leader>sf', '<cmd>Telescope find_files<cr>',   desc = '[S]earch [F]iles' },
      { '<leader>ss', '<cmd>Telescope builtin<cr>',      desc = '[S]earch [S]elect Telescope' },
      { '<leader>sw', '<cmd>Telescope grep_string<cr>',  desc = '[S]earch current [W]ord' },
      { '<leader>fg', '<cmd>Telescope live_grep<cr>',    desc = '[F]ind by [G]rep' },
      { '<leader>sd', '<cmd>Telescope diagnostics<cr>',  desc = '[S]earch [D]iagnostics' },
      { '<leader>sr', '<cmd>Telescope resume<cr>',       desc = '[S]earch [R]esume' },
      { '<leader>s.', '<cmd>Telescope oldfiles<cr>',     desc = '[S]earch Recent Files' },
      { '<leader><leader>', '<cmd>Telescope buffers<cr>', desc = 'Find existing buffers' },
      { '<leader>ff', '<cmd>Telescope find_files<cr>',   desc = 'Find files' },
      { '<leader>fb', '<cmd>Telescope buffers<cr>',      desc = 'Find buffer' },
      {
        '<leader>fh',
        function()
          require('core.telescope_help').show()
        end,
        desc = 'Telescope help',
      },
      { '<leader>fr', '<cmd>Telescope lsp_references<cr>', desc = 'Find references' },
      { '<leader>fd', desc = 'Find directory' },
      { '<leader>lg', '<cmd>Telescope live_grep<cr>',    desc = 'Live grep in cwd' },
      {
        '<leader>/',
        function()
          require('telescope.builtin').current_buffer_fuzzy_find(
            require('telescope.themes').get_dropdown({ winblend = 10, previewer = false })
          )
        end,
        desc = 'Fuzzy search current buffer',
      },
      {
        '<leader>s/',
        function()
          require('telescope.builtin').live_grep({
            grep_open_files = true,
            prompt_title = 'Live Grep in Open Files',
          })
        end,
        desc = '[S]earch [/] in Open Files',
      },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond  = function() return vim.fn.executable('make') == 1 end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      local actions = require('telescope.actions')

      local ts_ok, ts_parsers = pcall(require, 'nvim-treesitter.parsers')
      if ts_ok and ts_parsers.ft_to_lang == nil then
        ts_parsers.ft_to_lang = function(filetype)
          return vim.treesitter.language.get_lang(filetype) or filetype
        end
      end
      local ts_configs_ok, ts_configs = pcall(require, 'nvim-treesitter.configs')
      if ts_configs_ok and ts_configs.is_enabled == nil then
        ts_configs.is_enabled = function()
          return false
        end
      elseif not ts_configs_ok then
        package.preload['nvim-treesitter.configs'] = function()
          return {
            is_enabled = function()
              return false
            end,
          }
        end
      end

      require('telescope').setup({
        defaults = {
          mappings = {
            i = {
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,
            },
            n = {
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,
            },
          },
          preview = {
            -- Telescope 0.1.x calls removed nvim-treesitter APIs on Neovim 0.12.
            -- Use regex preview highlighting; editor buffers still use treesitter.
            treesitter = false,
          },
        },
        pickers = {
          buffers = {
            mappings = {
              n = {
                ['dd'] = actions.delete_buffer,
              },
            },
          },
        },
        extensions = {
          ['ui-select'] = { require('telescope.themes').get_dropdown() },
        },
      })

      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      local b = require('telescope.builtin')

      -- ── Core search ──────────────────────────────────────────────────────
      vim.keymap.set('n', '<leader>sh', b.help_tags,     { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', b.keymaps,       { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', b.find_files,    { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', b.builtin,       { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', b.grep_string,   { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>fg', b.live_grep,     { desc = '[F]ind by [G]rep' })
      vim.keymap.set('n', '<leader>sd', b.diagnostics,   { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', b.resume,        { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', b.oldfiles,      { desc = '[S]earch Recent Files' })
      vim.keymap.set('n', '<leader><leader>', b.buffers, { desc = 'Find existing buffers' })

      -- ── File shortcuts ────────────────────────────────────────────────────
      vim.keymap.set('n', '<leader>ff', b.find_files,        { desc = 'Find files' })
      vim.keymap.set('n', '<leader>fb', b.buffers,           { desc = 'Find buffer' })
      vim.keymap.set('n', '<leader>fh', function()
        require('core.telescope_help').show()
      end, { desc = 'Telescope help' })
      vim.keymap.set('n', '<leader>fr', b.lsp_references,    { desc = 'Find references' })

      -- ── Live grep in the current working directory ────────────────────────
      vim.keymap.set('n', '<leader>lg', function()
        b.live_grep({ cwd = vim.fn.getcwd() })
      end, { desc = 'Live grep in cwd' })

      -- ── Fuzzy search within the current buffer ────────────────────────────
      vim.keymap.set('n', '<leader>/', function()
        b.current_buffer_fuzzy_find(
          require('telescope.themes').get_dropdown({ winblend = 10, previewer = false })
        )
      end, { desc = '[/] Fuzzy search current buffer' })

      -- ── Grep across all open files ────────────────────────────────────────
      vim.keymap.set('n', '<leader>s/', function()
        b.live_grep({ grep_open_files = true, prompt_title = 'Live Grep in Open Files' })
      end, { desc = '[S]earch [/] in Open Files' })

      -- ── Search your Neovim config ─────────────────────────────────────────
      vim.keymap.set('n', '<leader>sn', function()
        b.find_files({ cwd = vim.fn.stdpath('config') })
      end, { desc = '[S]earch [N]eovim config' })

      -- ── Find directory — Enter to cd, C-g to grep inside ─────────────────
      vim.keymap.set('n', '<leader>fd', function()
        local actions     = require('telescope.actions')
        local state       = require('telescope.actions.state')
        local fd_cmd      = vim.fn.executable('fd') == 1
          and { 'fd', '--type', 'd', '--hidden', '--follow', '--exclude', '.git' }
          or  { 'find', '.', '-type', 'd', '-not', '-path', '*/.git/*' }

        b.find_files({
          prompt_title = '  Find Directory',
          find_command = fd_cmd,
          attach_mappings = function(prompt_bufnr, map)
            -- Enter → cd into the selected directory
            actions.select_default:replace(function()
              local entry = state.get_selected_entry()
              actions.close(prompt_bufnr)
              if entry then
                local dir = entry.path or entry.value
                vim.fn.chdir(dir)
                vim.notify('cwd → ' .. vim.fn.fnamemodify(dir, ':~'), vim.log.levels.INFO)
              end
            end)

            -- C-g → live grep scoped to the selected directory
            map('i', '<C-g>', function()
              local entry = state.get_selected_entry()
              actions.close(prompt_bufnr)
              if entry then
                local dir   = entry.path or entry.value
                local label = vim.fn.fnamemodify(dir, ':~:.')
                b.live_grep({
                  search_dirs  = { dir },
                  prompt_title = '  Grep in ' .. label,
                })
              end
            end)
            map('n', '<C-g>', function()
              local entry = state.get_selected_entry()
              actions.close(prompt_bufnr)
              if entry then
                local dir   = entry.path or entry.value
                local label = vim.fn.fnamemodify(dir, ':~:.')
                b.live_grep({
                  search_dirs  = { dir },
                  prompt_title = '  Grep in ' .. label,
                })
              end
            end)

            return true
          end,
        })
      end, { desc = '[F]ind [D]irectory' })
    end,
  },

  -- --------------------------------------------------------------------------
  -- Treesitter — parsers + highlighting (Neovim 0.12 requires the `main` branch)
  -- --------------------------------------------------------------------------
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy   = false,
    build  = ':TSUpdate',
    config = function()
      require('nvim-treesitter').setup({
        install_dir = vim.fn.stdpath('data') .. '/site',
      })
    end,
  },

  -- --------------------------------------------------------------------------
  -- Comment.nvim — gc / gb to toggle line / block comments
  -- --------------------------------------------------------------------------
  { 'numToStr/Comment.nvim', opts = {} },

}
