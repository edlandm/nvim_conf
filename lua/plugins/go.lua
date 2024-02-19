return {
  "ray-x/go.nvim",
  dependencies = {  -- optional packages
    "ray-x/guihua.lua",
    "neovim/nvim-lspconfig",
    "nvim-treesitter/nvim-treesitter",
  },
  build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
  event = {"CmdlineEnter"},
  ft = {"go", 'gomod'},
  config = function()
    require("go").setup()
    -- format on write
    local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*.go",
      callback = function() vim.cmd("GoFmt") end,
      group = format_sync_grp,
    })
  end,
  keys = {
    {'<localleader>t', '<cmd>GoTest<cr>', 'n', desc = 'Run Tests'},
  },
}
