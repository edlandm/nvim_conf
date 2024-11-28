local function set_maps()
  require("mappings").nmap({
    { "Run Go Tests", "<localleader>t", "<cmd>GoTest<cr>" },
  })
end

return {
  "ray-x/go.nvim",
  dependencies = {  -- optional packages
    "ray-x/guihua.lua",
    "neovim/nvim-lspconfig",
    "nvim-treesitter/nvim-treesitter",
  },
  build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
  ft = {"go", 'gomod'},
  init = function ()
    require('autocmd').augroup('GOLANG', {
      { { 'BufEnter', 'BufNewFile' }, { pattern = '*.go', callback = set_maps } },
      { { 'FileType' }, { pattern = 'go', callback = set_maps } },
      { { 'BufWritePre' }, { pattern = '*.go', command = 'GoFmt' } },
    })
  end,
  config = function()
    require("go").setup({
      lsp_codelense = false,
    })
  end,
}
