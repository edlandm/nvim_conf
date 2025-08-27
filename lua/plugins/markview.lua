return {
  "OXY2DEV/markview.nvim",
  lazy = false,      -- Recommended
  -- ft = "markdown" -- If you decide to lazy-load anyway
  priority = 30,
  opts = {
    code_blocks = {
      icons = 'mini'
    },
  },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    -- "nvim-tree/nvim-web-devicons",
  },
}
