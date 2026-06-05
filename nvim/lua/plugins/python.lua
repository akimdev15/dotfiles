-- ============================================================================
-- Python: REPL manager and virtualenv selector
-- Both plugins are lazy — they load only when a Python file is opened.
-- ============================================================================
return {

  -- --------------------------------------------------------------------------
  -- venv-selector — pick a Python virtualenv and auto-notify pyright + iron
  -- Loads on <leader>pv or when a Python file is opened.
  -- --------------------------------------------------------------------------
  {
    'linux-cultist/venv-selector.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim', 'neovim/nvim-lspconfig' },
    ft           = 'python',
    keys         = {
      { '<leader>pv', '<cmd>VenvSelect<cr>', desc = 'Select Python venv' },
    },
    config = function()
      require('venv-selector').setup()
    end,
  },

  -- --------------------------------------------------------------------------
  -- iron.nvim — interactive Python REPL
  -- Loads the first time any Python file is opened.
  --
  -- Global (available after first .py file opens):
  --   <F5>          save + run file in a terminal split
  --   <leader>pp    open / focus REPL
  --   <leader>ph    hide REPL window (session stays alive)
  --   <leader>pr    restart REPL
  --
  -- Python buffers only:
  --   <leader>pl    send current line
  --   <leader>ps    send visual selection
  --   <leader>pf    send entire file
  --   <leader>pi    interrupt (Ctrl-C)
  --   <leader>pc    clear REPL output
  -- --------------------------------------------------------------------------
  {
    'Vigemus/iron.nvim',
    ft = 'python',
    config = function()
      local iron = require('iron.core')

      iron.setup({
        config = {
          scratch_repl    = true,
          repl_definition = {
            python = { command = { 'python3' } },
          },
          repl_open_cmd = 'botright 15split',
        },
        keymaps            = {},
        highlight          = { italic = true },
        ignore_blank_lines = true,
      })

      -- ── Python-buffer keymaps ─────────────────────────────────────────────
      vim.api.nvim_create_autocmd('FileType', {
        pattern  = 'python',
        callback = function(ev)
          local map = function(mode, lhs, fn, desc)
            vim.keymap.set(mode, lhs, fn, { buffer = ev.buf, desc = desc })
          end
          map('n', '<leader>pl', function() iron.send_line() end,                'Send line to REPL')
          map('v', '<leader>ps', function() iron.visual_send() end,              'Send selection to REPL')
          map('n', '<leader>pf', function() iron.send_file() end,                'Send file to REPL')
          map('n', '<leader>pi', function() iron.send(nil, string.char(03)) end, 'Interrupt REPL')
          map('n', '<leader>ph', '<cmd>IronHide<cr>',                            'Hide REPL')
          map('n', '<leader>pc', '<cmd>IronSend clear<cr>',                      'Clear REPL')
        end,
      })

      -- ── Global keymaps set after plugin loads ─────────────────────────────
      vim.keymap.set('n', '<F5>', function()
        if vim.bo.filetype ~= 'python' then
          vim.notify('Not a Python file', vim.log.levels.WARN)
          return
        end
        vim.cmd('write')
        vim.cmd('botright 15split | terminal python3 ' .. vim.fn.expand('%:p'))
        vim.cmd('startinsert')
      end, { desc = 'Run Python file' })

      vim.keymap.set('n', '<leader>pp', '<cmd>IronRepl<cr>',    { desc = 'Open Python REPL' })
      vim.keymap.set('n', '<leader>ph', '<cmd>IronHide<cr>',    { desc = 'Hide REPL' })
      vim.keymap.set('n', '<leader>pr', '<cmd>IronRestart<cr>', { desc = 'Restart REPL' })
    end,
  },

}
