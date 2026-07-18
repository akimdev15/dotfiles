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
          cmd      = cmd,
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

        -- Re-resolve the Maven or Gradle classpath into the jdtls workspace.
        -- Needed after editing pom.xml to add a dependency, or when the workspace
        -- goes stale, for example after a Gradle to Maven conversion, which shows
        -- up as third party imports failing to resolve while your own packages are
        -- fine. Same effect as the :JdtUpdateConfig command.
        vim.keymap.set('n', '<leader>ju', function()
          jdtls.update_project_config()
          vim.notify('jdtls: project config updated', vim.log.levels.INFO)
        end, { buffer = true, desc = '[J]dtls [U]pdate project config' })

        -- Run the build's generate-sources phase, which produces the Avro Java
        -- types and any annotation processor output, then refresh jdtls so the
        -- generated classes resolve without a red import.
        local mvn = vim.fn.filereadable(root .. '/mvnw') == 1 and (root .. '/mvnw') or 'mvn'
        vim.keymap.set('n', '<leader>jg', function()
          vim.notify('maven: generate-sources running', vim.log.levels.INFO)
          vim.system({ mvn, '-q', 'generate-sources' }, { cwd = root }, function(obj)
            vim.schedule(function()
              if obj.code == 0 then
                jdtls.update_project_config()
                vim.notify('maven: generate-sources done, jdtls refreshed', vim.log.levels.INFO)
              else
                vim.notify('maven generate-sources failed\n' .. (obj.stderr or ''), vim.log.levels.ERROR)
              end
            end)
          end)
        end, { buffer = true, desc = '[J]ava [G]enerate sources' })
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

      -- Auto re-resolve the classpath when a build file is saved, so a newly
      -- added dependency resolves without manually running <leader>ju. Only fires
      -- when a jdtls client is already running for the session.
      vim.api.nvim_create_autocmd('BufWritePost', {
        pattern = { 'pom.xml', 'build.gradle', 'build.gradle.kts', 'settings.gradle', 'settings.gradle.kts' },
        callback = function()
          if #vim.lsp.get_clients({ name = 'jdtls' }) > 0 then
            require('jdtls').update_project_config()
            vim.notify('jdtls: project config updated after build file save', vim.log.levels.INFO)
          end
        end,
      })
    end,
  },
}
