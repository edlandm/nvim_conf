return {
  'neovim/nvim-lspconfig',
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
  end,
  ft = {
      'rust',
      'cs',
  },
  dependencies = {
    'simrat39/rust-tools.nvim',
    'hrsh7th/cmp-nvim-lsp',
  }
}
