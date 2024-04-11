return {
  'stevearc/oil.nvim',
  opts = {
    default_file_explorer = true,
  },
  event = "VimEnter",
  -- Optional dependencies
  dependencies = {
    "nvim-tree/nvim-web-devicons"
  },
  config = true,
}
