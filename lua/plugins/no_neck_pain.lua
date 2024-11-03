return {
  "shortcuts/no-neck-pain.nvim",
  lazy = false,
  version = "*",
  opts = {
    width = 100,
    minSideBufferWidth = 20,
    buffers = {
      scratchPad = {
        enabled = false, -- disable auto-saving
      },
      bo = {
        filetype = "markdown",
      },
      right = {
        enabled = false,
      },
    },
  },
  keys = {
    { "<c-n>", "<cmd>lua require('no-neck-pain').toggle()<cr>", desc = "NoNeckPain" },
  },
}
