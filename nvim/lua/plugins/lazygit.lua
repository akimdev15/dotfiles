return {
  'kdheepak/lazygit.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  cmd = { 'LazyGit', 'LazyGitConfig', 'LazyGitCurrentFile', 'LazyGitFilter', 'LazyGitFilterCurrentFile' },
  keys = {
    { '<leader>gg', '<cmd>LazyGit<CR>', desc = 'Open Lazygit' },
  },
  config = function()
    vim.g.lazygit_floating_window_winblend = 0
    vim.g.lazygit_floating_window_scaling_factor = 0.9
    vim.g.lazygit_floating_window_border_chars = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' }
    vim.g.lazygit_use_neovim_remote = 0
  end,
}
