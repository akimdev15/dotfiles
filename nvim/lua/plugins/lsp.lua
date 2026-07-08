-- ============================================================================
-- LSP, Mason, Completion, and Formatting
-- ============================================================================
return {

  -- Neovim Lua API completions — only needed when editing .lua files
  { 'folke/neodev.nvim', ft = 'lua', opts = {} },

  -- Mason is for installing/updating tools. Keep it off the file-open path.
  {
    'williamboman/mason.nvim',
    cmd = { 'Mason', 'MasonInstall', 'MasonUninstall', 'MasonUpdate' },
    opts = {},
  },

  {
    'williamboman/mason-lspconfig.nvim',
    cmd = { 'LspInstall', 'LspUninstall' },
    dependencies = { 'williamboman/mason.nvim' },
    opts = {
      automatic_enable = false,
    },
  },

  -- Auto-installs Mason tools on startup so a fresh clone has everything ready.
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    event = 'VeryLazy',
    opts = (function()
      local cfg = require('core.config')
      local function on(flag) return cfg.prefer_rust and cfg[flag] end

      local tools = {
        -- LSP servers
        'gopls',           -- Go
        'jdtls',           -- Java
        'pyright',         -- Python
        'typescript-language-server',
        'lua-language-server',


        -- Formatters (always)
        'stylua',          -- Lua  (Rust)
        'ruff',             -- Python (Rust)
        'google-java-format',
        'goimports',       -- Go
        'golines',         -- Go line wrap
        -- Note: pg_format installed via Homebrew (see dotfiles/init_setup.sh)
      }

      -- prettier vs prettierd (identical output, daemon = fast)
      table.insert(tools, on('use_prettierd') and 'prettierd' or 'prettier')

      if on('use_taplo')  then table.insert(tools, 'taplo')  end
      if on('use_biome')  then table.insert(tools, 'biome')  end
      if on('use_dprint') then table.insert(tools, 'dprint') end

      return { run_on_start = true, ensure_installed = tools }
    end)(),
  },

  -- --------------------------------------------------------------------------
  -- Core LSP configuration
  -- --------------------------------------------------------------------------
  {
    'neovim/nvim-lspconfig',
    ft = {
      'go',
      'javascript',
      'javascriptreact',
      'lua',
      'python',
      'typescript',
      'typescriptreact',
    },
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      { 'j-hui/fidget.nvim', opts = {} },
    },
    -- init runs at startup regardless of ft lazy-loading, so keymaps fire for
    -- ALL LSP clients (including nvim-jdtls for Java which never triggers ft above)
    init = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          local telescope = function(name)
            return function()
              require('telescope.builtin')[name]()
            end
          end

          map('gd',         telescope('lsp_definitions'),               '[G]oto [D]efinition')
          map('gr',         telescope('lsp_references'),                '[G]oto [R]eferences')
          map('gI',         telescope('lsp_implementations'),           '[G]oto [I]mplementation')
          map('gD',         vim.lsp.buf.declaration,                    '[G]oto [D]eclaration')
          map('<leader>D',  telescope('lsp_type_definitions'),          'Type [D]efinition')
          map('<leader>ds', telescope('lsp_document_symbols'),          '[D]ocument [S]ymbols')
          map('<leader>ws', telescope('lsp_dynamic_workspace_symbols'), '[W]orkspace [S]ymbols')
          map('<leader>rn', vim.lsp.buf.rename,                         '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action,                    '[C]ode [A]ction')
          map('<leader>oi', function()
            vim.lsp.buf.code_action({
              context = { only = { 'source.organizeImports' }, diagnostics = {} },
              apply   = true,
            })
          end, '[O]rganize [I]mports')
          map('<C-s>', function()
            vim.lsp.buf.signature_help({ border = 'rounded' })
          end, 'Signature Help')
          map('K', function()
            vim.lsp.buf.hover({ border = 'rounded' })
          end, 'Hover Documentation')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer   = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer   = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })
    end,
    config = function()
      local mason_bin = vim.fn.stdpath('data') .. '/mason/bin'
      if not vim.env.PATH:find(mason_bin, 1, true) then
        vim.env.PATH = mason_bin .. ':' .. vim.env.PATH
      end

      -- ── UI Enhancements ──────────────────────────────────────────────────
      vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = 'rounded',
      })
      vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = 'rounded',
      })

      -- ── LSP capabilities (enhanced by nvim-cmp) ───────────────────────────
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend(
        'force', capabilities,
        require('cmp_nvim_lsp').default_capabilities()
      )

      -- ── Servers to auto-install and configure ─────────────────────────────
      -- Add or remove entries here to manage which LSPs are active.
      local servers = {
        gopls   = {},
        pyright = {},
        ts_ls   = {},
        lua_ls  = {
          settings = {
            Lua = {
              completion = { callSnippet = 'Replace' },
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      for server_name, server in pairs(servers) do
        server.capabilities = vim.tbl_deep_extend(
          'force', {}, capabilities, server.capabilities or {}
        )
        vim.lsp.config(server_name, server)
        vim.lsp.enable(server_name)
      end

    end,
  },

  -- --------------------------------------------------------------------------
  -- (conform.nvim moved to plugins/format.lua)
  -- --------------------------------------------------------------------------
  -- nvim-cmp — autocompletion engine
  -- --------------------------------------------------------------------------
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          if vim.fn.has('win32') == 1 or vim.fn.executable('make') == 0 then return end
          return 'make install_jsregexp'
        end)(),
      },
      'saadparwaiz1/cmp_luasnip', -- LuaSnip completion source
      'hrsh7th/cmp-nvim-lsp',     -- LSP completion source
      'hrsh7th/cmp-path',         -- filesystem path completion
    },
    config = function()
      local cmp     = require('cmp')
      local luasnip = require('luasnip')
      luasnip.config.setup({})

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },
        mapping    = cmp.mapping.preset.insert({
          ['<C-j>']     = cmp.mapping.select_next_item(),
          ['<C-k>']     = cmp.mapping.select_prev_item(),
          ['<C-y>']     = cmp.mapping.confirm({ select = true }),
          ['<C-Space>'] = cmp.mapping.complete({}),
          -- Snippet navigation: <C-l> → forward, <C-h> → backward
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then luasnip.expand_or_jump() end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then luasnip.jump(-1) end
          end, { 'i', 's' }),
        }),
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        },
      })
    end,
  },

}
