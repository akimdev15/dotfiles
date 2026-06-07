-- ============================================================================
-- Tools: file explorer and tmux integration
-- ============================================================================
return {

  -- --------------------------------------------------------------------------
  -- neo-tree — modern file explorer
  --
  --   <leader>e   floating popup  (reveals current file if open, else toggle)
  --   <leader>t   left sidebar    (reveals current file if open, else toggle)
  --
  -- Inside neo-tree (both float and sidebar):
  --   o / <Enter> open file OR expand/collapse folder
  --   l           open (vim-style right)
  --   h           collapse node (vim-style left)
  --   a           add file/directory (end name with / to create a directory)
  --   d           delete
  --   r           rename
  --   y           copy filename
  --   x           cut
  --   p           paste
  --   s           open in vertical split
  --   S           open in horizontal split
  --   t           open in new tab
  --   H           toggle hidden / dotfiles
  --   P           float preview of file under cursor
  --   R           refresh tree
  --   q           close
  -- --------------------------------------------------------------------------
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch       = 'v3.x',
    init = function()
      -- neo-tree must disable netrw before anything else loads
      vim.g.loaded_netrw       = 1
      vim.g.loaded_netrwPlugin = 1
    end,
    cmd = 'Neotree',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    keys = {
      {
        '<leader>e',
        function()
          local has_file = vim.bo.buftype == '' and vim.api.nvim_buf_get_name(0) ~= ''
          require('neo-tree.command').execute({ toggle = true, reveal = has_file, position = 'float' })
        end,
        desc = 'Float file explorer',
      },
      {
        '<leader>t',
        function()
          local has_file = vim.bo.buftype == '' and vim.api.nvim_buf_get_name(0) ~= ''
          require('neo-tree.command').execute({ toggle = true, reveal = has_file, position = 'left' })
        end,
        desc = 'Sidebar file explorer',
      },
    },
    opts = {
      close_if_last_window = true,
      popup_border_style   = 'rounded',
      -- Skip loading buffers/git_status source modules — we only open the filesystem tree.
      sources              = { 'filesystem' },
      -- Don't re-scan tree after every :w in a child file.
      enable_refresh_on_write = false,
      -- gitsigns.nvim already shows git status in the editor gutter.
      -- Keeping this enabled causes neo-tree to run git subprocesses and do
      -- worktree/status lookups on every folder expand — measurably slow.
      enable_git_status  = false,
      enable_diagnostics = false, -- querying LSP on every expand is slow
      default_component_configs = {
        indent = {
          indent_size    = 2,
          with_markers   = true,
          with_expanders = true,
        },
        icon = {
          folder_closed = '',
          folder_open   = '',
          folder_empty  = '󰜌',
          default       = '*',
        },
        git_status = {
          symbols = {
            added     = '✚',
            modified  = '',
            deleted   = '✖',
            renamed   = '󰁕',
            untracked = '',
            ignored   = '',
            unstaged  = '󰄱',
            staged    = '',
            conflict  = '',
          },
        },
      },
      window = {
        position = 'left',
        width    = 35,
        mappings = {
          ['<space>']        = 'none',       -- don't let neo-tree intercept <leader>
          -- nowait = true: fire immediately without waiting for any chord timeout
          ['<cr>']           = { 'open', nowait = true },
          ['<LeftMouse>']    = { 'open', nowait = true }, -- single-click opens without double-click delay
          ['o']              = { 'open', nowait = true },
          ['l']              = { 'open', nowait = true }, -- l → open (vim-style move right)
          ['h']       = 'close_node', -- h     → collapse (vim-style move left)
          ['H']       = 'toggle_hidden',
          ['P']       = { 'toggle_preview', config = { use_float = true } },
          ['s']       = 'open_vsplit',
          ['S']       = 'open_split',
          ['t']       = 'open_tabnew',
        },
      },
      filesystem = {
        filtered_items = {
          hide_dotfiles   = false,
          hide_gitignored = true,
        },
        -- Off by default: when enabled, every BufEnter rescans the tree to reveal
        -- the open file (fs_scan + git status). That makes neo-tree opens feel very slow.
        hijack_netrw_behavior  = 'disabled',    -- don't auto-open on nvim .
        follow_current_file    = { enabled = false, leave_dirs_open = true },
        use_libuv_file_watcher = false,   -- macOS: libuv watchers on expand = very slow
        -- 'always' overrides the hardcoded async=false in toggle_directory, making
        -- folder expands non-blocking. 'auto' only applies when nil is passed.
        async_directory_scan   = 'always',
        scan_mode              = 'shallow', -- only scan one level deep at a time
      },
    },
  },

  -- --------------------------------------------------------------------------
  -- vim-tmux-navigator — seamless navigation between tmux panes and vim splits
  -- Requires matching config in ~/.tmux.conf
  -- --------------------------------------------------------------------------
  {
    'christoomey/vim-tmux-navigator',
    cmd = {
      'TmuxNavigateLeft', 'TmuxNavigateDown',
      'TmuxNavigateUp',   'TmuxNavigateRight', 'TmuxNavigatePrevious',
    },
    keys = {
      { '<c-h>',  '<cmd><C-U>TmuxNavigateLeft<cr>' },
      { '<c-j>',  '<cmd><C-U>TmuxNavigateDown<cr>' },
      { '<c-k>',  '<cmd><C-U>TmuxNavigateUp<cr>' },
      { '<c-l>',  '<cmd><C-U>TmuxNavigateRight<cr>' },
      { '<c-\\>', '<cmd><C-U>TmuxNavigatePrevious<cr>' },
    },
  },

}
