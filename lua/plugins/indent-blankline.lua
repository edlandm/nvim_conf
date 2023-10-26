return {
  "lukas-reineke/indent-blankline.nvim",
  dependencies = {
    'HiPhish/rainbow-delimiters.nvim',
  },
  event = "VimEnter",
  main = "ibl",
  opts = {},
  config = function()
    local highlight = {
      "RainbowViolet",
      "RainbowGreen",
      "RainbowBlue",
      "RainbowRed",
      "RainbowYellow",
      "RainbowCyan",
      "RainbowOrange",
    }

    local hooks = require "ibl.hooks"
    -- create the highlight groups in the highlight setup hook, so they are reset
    -- every time the colorscheme changes
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
      vim.api.nvim_set_hl(0, "RainbowGreen",  { fg = "#98C379" })
      vim.api.nvim_set_hl(0, "RainbowBlue",   { fg = "#61AFEF" })
      vim.api.nvim_set_hl(0, "RainbowRed",    { fg = "#E06C75" })
      vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
      vim.api.nvim_set_hl(0, "RainbowCyan",   { fg = "#56B6C2" })
      vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
    end)

    require("ibl").setup { indent = { highlight = highlight } }
  end,
}
