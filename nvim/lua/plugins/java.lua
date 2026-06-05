-- ============================================================================
-- Java LSP via nvim-jdtls
-- Install server: :MasonInstall jdtls
-- ============================================================================
return {
  {
    'mfussenegger/nvim-jdtls',
    ft = 'java',
    config = function()
      local jdtls    = require('jdtls')
      local mason_bin = vim.fn.stdpath('data') .. '/mason/bin'

      -- Unique workspace per project so jdtls state doesn't bleed across projects
      local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
      local workspace    = vim.fn.stdpath('data') .. '/jdtls-workspace/' .. project_name

      local config = {
        cmd = { mason_bin .. '/jdtls', '-data', workspace },

        root_dir = vim.fs.dirname(
          vim.fs.find({ 'gradlew', 'mvnw', 'pom.xml', 'build.gradle', '.git' }, { upward = true })[1]
        ) or vim.fn.getcwd(),

        settings = {
          java = {
            format    = { enabled = true },
            signatureHelp = { enabled = true },
            completion = { importOrder = { 'java', 'javax', 'com', 'org' } },
          },
        },

        capabilities = (function()
          local ok, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
          local base = vim.lsp.protocol.make_client_capabilities()
          return ok and vim.tbl_deep_extend('force', base, cmp_lsp.default_capabilities()) or base
        end)(),
      }

      jdtls.start_or_attach(config)
    end,
  },
}
