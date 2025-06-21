return {
  { 'rafamadriz/friendly-snippets' },
  {
    'L3MON4D3/LuaSnip',
    build = "make install_jsregexp",
    event = 'VeryLazy',
    depencies = {
      'rafamadriz/friendly-snippets',
    },
    config = function()
      require("luasnip.loaders.from_lua").load({
        paths = {
          vim.fn.stdpath('config') .. '/snippets',
        }
      })
      require("luasnip.loaders.from_vscode").lazy_load({
        paths = {
          vim.fn.stdpath('config') .. '/snippets',
          vim.fn.stdpath('data') .. '/lazy/friendly-snippets',
        },
      })
    end,
  },
}
