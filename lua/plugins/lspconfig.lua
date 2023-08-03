return {
  'neovim/nvim-lspconfig',
  event = "VeryLazy",
  config = function()
    require('lspconfig').rust_analyzer.setup({
      settings = {
        ['rust-analyzer'] = {
          diagnostics = {
            enable = false,
          },
        },
      },
    })
  end,
  ft = {
    'rust',
  },
  dependencies = {
    'simrat39/rust-tools.nvim',
    'hrsh7th/cmp-nvim-lsp',
  }
}
