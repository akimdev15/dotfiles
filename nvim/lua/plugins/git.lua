-- ============================================================================
-- Git: gutter signs for uncommitted changes
-- ============================================================================
return {
  {
    'lewis6991/gitsigns.nvim',
    -- Only ever attaches inside a git worktree, so cost is zero elsewhere.
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      signs = {
        add          = { text = '│' },
        change       = { text = '│' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
      },
      -- Diffs run via an async `git diff`, debounced — doesn't block typing.
      -- Skip pathologically large files outright rather than diffing them.
      max_file_length = 40000,
      current_line_blame = false, -- off by default; toggle with <leader>gb
      current_line_blame_opts = {
        delay = 300,
        virt_text_pos = 'eol',
      },
      on_attach = function(bufnr)
        local gitsigns = require('gitsigns')
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end

        -- ── Hunk navigation ────────────────────────────────────────────────
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal({ ']c', bang = true })
          else
            gitsigns.nav_hunk('next')
          end
        end, 'Next git hunk')
        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal({ '[c', bang = true })
          else
            gitsigns.nav_hunk('prev')
          end
        end, 'Previous git hunk')

        -- ── Hunk actions ───────────────────────────────────────────────────
        map('n', '<leader>hs', gitsigns.stage_hunk,   'Stage hunk')
        map('n', '<leader>hr', gitsigns.reset_hunk,   'Reset hunk')
        map('v', '<leader>hs', function()
          gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, 'Stage hunk')
        map('v', '<leader>hr', function()
          gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, 'Reset hunk')
        map('n', '<leader>hS', gitsigns.stage_buffer,  'Stage buffer')
        map('n', '<leader>hR', gitsigns.reset_buffer,  'Reset buffer')
        map('n', '<leader>hp', gitsigns.preview_hunk,  'Preview hunk')
        map('n', '<leader>hb', function() gitsigns.blame_line({ full = true }) end, 'Blame line')

        -- ── Toggles ────────────────────────────────────────────────────────
        -- Not <leader>tb: <leader>t is already bound (sidebar toggle) and
        -- sharing that prefix would add input-timeout latency to it.
        map('n', '<leader>gb', gitsigns.toggle_current_line_blame, 'Toggle line blame')

        -- ── Text object — e.g. `dih` deletes the current hunk ─────────────
        map({ 'o', 'x' }, 'ih', gitsigns.select_hunk, 'Select git hunk')
      end,
    },
  },
}
