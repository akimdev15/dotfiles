-- ============================================================================
-- Testing: vim-test
-- Shells out to ./mvnw or ./gradlew — no DAP or adapter wiring needed.
-- ============================================================================
return {
  {
    'vim-test/vim-test',
    keys = {
      { '<leader>nn', '<cmd>TestNearest<cr>', desc = 'Test nearest' },
      { '<leader>nf', '<cmd>TestFile<cr>',    desc = 'Test file' },
      { '<leader>ns', '<cmd>TestSuite<cr>',   desc = 'Test suite' },
      { '<leader>nl', '<cmd>TestLast<cr>',    desc = 'Test last' },
    },
    config = function()
      vim.g['test#strategy']                   = 'neovim'
      vim.g['test#neovim#term_position']       = 'belowright split'
      vim.g['test#neovim#start_normal']        = 1
      vim.g['test#java#maventest#executable']  = './mvnw'
      vim.g['test#java#gradletest#executable'] = './gradlew'
    end,
  },
}
