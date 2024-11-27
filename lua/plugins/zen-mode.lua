return {
  "folke/zen-mode.nvim",
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    window = {
      backdrop = 0.95, -- shade the backdrop of the Zen window. Set to 1 to keep the same as Normal
      height = 1,
      width = .65,
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
