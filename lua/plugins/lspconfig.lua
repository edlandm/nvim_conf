return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'simrat39/rust-tools.nvim',
    'hrsh7th/cmp-nvim-lsp',
    'rmagatti/goto-preview',
  },
  event = "VeryLazy",
  config = function()
    local lspconfig = require('lspconfig')
    lspconfig.rust_analyzer.setup({
      settings = {
        ['rust-analyzer'] = {
          diagnostics = {
            enable = false,
          },
        },
      },
    })
    lspconfig.csharp_ls.setup({
      root_dir = function(startpath)
        return lspconfig.util.root_pattern("*.sln")(startpath)
          or lspconfig.util.root_pattern("*.csproj")(startpath)
          or lspconfig.util.root_pattern("*.fsproj")(startpath)
          or lspconfig.util.root_pattern(".git")(startpath)
      end,
      on_attach = on_attach,
      capabilities = capabilities
    })
    lspconfig.gopls.setup({})
    lspconfig.bashls.setup({})
    lspconfig.lua_ls.setup({
      on_init = function(client)
        local path = client.workspace_folders[1].name
        if vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc') then
          return
        end

        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
          runtime = {
            -- Tell the language server which version of Lua you're using
            -- (most likely LuaJIT in the case of Neovim)
            version = 'LuaJIT'
          },
          -- Make the server aware of Neovim runtime files
          workspace = {
            checkThirdParty = false,
            library = {
              vim.env.VIMRUNTIME
              -- Depending on the usage, you might want to add additional paths here.
              -- "${3rd}/luv/library"
              -- "${3rd}/busted/library",
            }
            -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
            -- library = vim.api.nvim_get_runtime_file("", true)
          }
        })
      end,
      settings = {
        Lua = {}
      }
    })

    -- mappings
    vim.api.nvim_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
    -- code actions
    vim.api.nvim_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', { noremap = true, silent = true })
    -- rename variable
    vim.api.nvim_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', { noremap = true, silent = true })
  end,
}
