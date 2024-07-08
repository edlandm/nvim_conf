return {
  "folke/zen-mode.nvim",
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    window = {
      height = 0.97,
      width = 0.97,
    },
    plugins = {
      options = {
        ruler = true,
        showcmd = true,
        laststatus = 3,
      },
    },
  },
  cmd = "ZenMode",
  keys = {
    {"<leader>Z", "<cmd>ZenMode<cr>", desc = "ZenMode"},
  },
}
