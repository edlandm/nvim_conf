return {
  "Exafunction/windsurf.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  main = 'codeium',
  opts = {
    config_path = vim.fn.expand("~/.local/codeium.conf"),
  },
}
