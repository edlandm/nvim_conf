return {
  'L3MON4D3/LuaSnip',
  event = "InsertEnter",
  build = "make install_jsregexp",
  config = function()
    local luasnip = require('luasnip')
    luasnip.config.setup()
    local snippets_dir = vim.fn.stdpath("config") .. "/snippets"
    require("luasnip.loaders.from_vscode").lazy_load({paths = snippets_dir})
  end,
}
