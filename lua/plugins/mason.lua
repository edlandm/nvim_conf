return {
  'williamboman/mason.nvim',
  lazy = false,
  dependencies = {
    'williamboman/mason-lspconfig.nvim',
    'neovim/nvim-lspconfig',
    'folke/lazydev.nvim',
    'Decodetalkers/csharpls-extended-lsp.nvim',
  },
  opts = {
    configs = {
      lua_ls = {
        on_init = function(client)
          if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc') then
              return
            end
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
      },
    },
  },
  config = function(_, opts)
    local mason = require('mason')
    local mason_lspconfig = require('mason-lspconfig')
    local lspconfig = require('lspconfig')

    local ensure_installed = {}
    for ls, config in pairs(opts.configs) do
      if lspconfig[ls] then
        lspconfig[ls].setup(config)
      end
      vim.lsp.config(ls, config)
      table.insert(ensure_installed, ls)
    end

    mason.setup()
    mason_lspconfig.setup {
      ensure_installed = ensure_installed,
      automatic_enable = true,
    }
  end
}
