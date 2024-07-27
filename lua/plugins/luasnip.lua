return {
  'L3MON4D3/LuaSnip',
  event = "InsertEnter",
  build = "make install_jsregexp",
  config = function()
    local ls = require('luasnip')
    ls.config.setup()
    local snippets_dir = vim.fn.stdpath("config") .. "/snippets"
    require("luasnip.loaders.from_vscode").lazy_load({paths = snippets_dir})
    require("luasnip.loaders.from_lua").lazy_load({paths = snippets_dir})
  end,
}
