-- ============================================================================
-- Java LSP via nvim-jdtls
-- Install server: :MasonInstall jdtls
-- ============================================================================
return {
  {
    'mfussenegger/nvim-jdtls',
    ft = 'java',
    config = function()
      local function find_lombok_jar()
        local m2 = vim.fn.expand('~/.m2')
        local jars = vim.fn.glob(m2 .. '/repository/org/projectlombok/lombok/*/lombok-*.jar', false, true)
        jars = vim.tbl_filter(function(j) return not j:find('sources') end, jars)
        table.sort(jars)
        return jars[#jars]
      end

      local lombok_jar = find_lombok_jar()

      if not lombok_jar then
        vim.notify('nvim-jdtls: lombok jar not found in ~/.m2 — Lombok annotations may not resolve', vim.log.levels.WARN)
      end

      local function attach()
        local jdtls     = require('jdtls')
        local mason_bin = vim.fn.stdpath('data') .. '/mason/bin'

        local root = vim.fs.dirname(
          vim.fs.find({ 'gradlew', 'mvnw', 'pom.xml', 'build.gradle', '.git' }, { upward = true })[1]
        ) or vim.fn.getcwd()
        local project_name = vim.fn.fnamemodify(root, ':p:h:t')
        local workspace    = vim.fn.stdpath('data') .. '/jdtls-workspace/' .. project_name

        local cmd = { mason_bin .. '/jdtls', '-data', workspace }
        if lombok_jar then
          table.insert(cmd, 2, '--jvm-arg=-javaagent:' .. lombok_jar)
        end

        local config = {
          cmd = cmd,
          root_dir = root,
          settings = {
            java = {
              format        = { enabled = true },
              signatureHelp = { enabled = true },
              completion    = { importOrder = { 'java', 'javax', 'com', 'org' } },
            },
          },
          capabilities = (function()
            local ok, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
            local base = vim.lsp.protocol.make_client_capabilities()
            return ok and vim.tbl_deep_extend('force', base, cmp_lsp.default_capabilities()) or base
          end)(),
        }

        jdtls.start_or_attach(config)

        vim.keymap.set('n', '<leader>oi', jdtls.organize_imports,
          { buffer = true, desc = '[O]rganize [I]mports' })
      end

      vim.api.nvim_create_autocmd('FileType', {
        pattern  = 'java',
        callback = attach,
      })

      -- Fire for the buffer that triggered `ft = 'java'` lazy-load
      if vim.bo.filetype == 'java' then attach() end

      -- Belt-and-braces indent for buffers before/without LSP attach.
      vim.api.nvim_create_autocmd('FileType', {
        pattern  = 'java',
        callback = function()
          vim.bo.cindent     = true
          vim.bo.smartindent = false
        end,
      })

      -- Scaffold new .java files: package declaration + class skeleton.
      -- Fires on BufNewFile (`:e new.java`) AND BufReadPost when the file
      -- exists but is empty (e.g. neo-tree `a` creates the file on disk first).
      local function scaffold_java()
        if vim.api.nvim_buf_line_count(0) > 1
          or (vim.fn.getline(1) or '') ~= '' then
          return
        end

        local dir = vim.fn.expand('%:p:h')
        local pkg = dir:match('src/main/java/(.*)') or dir:match('src/test/java/(.*)')
        if not pkg then return end

        local class = vim.fn.expand('%:t:r')
        local lines = {
          'package ' .. pkg:gsub('/', '.') .. ';',
          '',
          'public class ' .. class .. ' {',
          '}',
          '',
        }
        vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
        vim.api.nvim_win_set_cursor(0, { 3, #lines[3] - 1 })
      end

      vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufReadPost' }, {
        pattern  = '*.java',
        callback = scaffold_java,
      })
    end,
  },
}
