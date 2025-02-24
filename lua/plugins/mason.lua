return {
  'williamboman/mason.nvim',
  lazy = false,
  dependencies = {
    'williamboman/mason-lspconfig.nvim',
    'neovim/nvim-lspconfig',
    'folke/lazydev.nvim',
    'Decodetalkers/csharpls-extended-lsp.nvim',
    'saghen/blink.cmp',
  },
  config = function()
    local mason = require('mason')
    local mason_lspconfig = require('mason-lspconfig')
    local lspconfig = require('lspconfig')

    local capabilities = {}
    local blink_installed, blink = pcall(require, 'blink.cmp')
    if blink_installed then
      blink.get_lsp_capabilities()
    end

    mason.setup()
    mason_lspconfig.setup()
    mason_lspconfig.setup_handlers({
      -- The first entry (without a key) will be the default handler
      -- and will be called for each installed server that doesn't have
      -- a dedicated handler.
      function (server_name) -- default handler (optional)
        lspconfig[server_name].setup { capabilities = capabilities }
      end,
      -- Next, you can provide a dedicated handler for specific servers.
      -- For example, a handler override for the `rust_analyzer`:
      -- ["rust_analyzer"] = function ()
      --   require("rust-tools").setup {}
      -- end
      ['lua_ls'] = function()
        lspconfig.lua_ls.setup({
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
          settings = {
            Lua = {}
          },
          capabilities = capabilities,
        })
      end,

      ['csharp_ls'] = function()
        local util = require('lspconfig.util')
        local ext_handler = require('csharpls_extended').handler
        local function is_projfile(name)
          return name:match('%.csproj$') ~= nil or name:match('%.sln$') ~= nil
        end
        local config = {
          handlers = {
            ['textDocument/definition']     = ext_handler,
            ['textDocument/typeDefinition'] = ext_handler,
          },
          root_dir = function(fname)
            local parent_dir = vim.fn.expand('%:p:h')
            local generated = vim.fs.joinpath(parent_dir, 'Generated')
            if vim.fn.isdirectory(generated) then
              local root = vim.fs.root(generated, is_projfile)
              if root then
                return root
              end
            end
            return vim.fs.root(fname, is_projfile)
          end,
          capabilities = capabilities,
        }
        lspconfig.csharp_ls.setup(config)
      end,
    })
  end
}
