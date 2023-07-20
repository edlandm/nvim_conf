return {
  "KaitlynEthylia/TreePin",
  dependencies = "nvim-treesitter/nvim-treesitter",
  config = true,
  cmd = {
    "TPPin",
    "TPRoot",
    "TPGrow",
    "TPShrink",
    "TPClear",
    "TPGo",
    "TPShow",
    "TPHide",
    "TPToggle",
  },
  keys = {
    { "<leader>pp", "<cmd>TPPin<cr>", desc = "Pin treesitter node under cursor" },
    { "<leader>pt", "<cmd>TPToggle<cr>", desc = "Toggle pinned node" },
    { "<leader>pc", "<cmd>TPClear<cr>", desc = "Remove Pin" },
    { "<leader>p'", "<cmd>TPGo<cr>", desc = "Jump to first line of pin" },
    { "<leader>p<", "<cmd>TPGrow<cr>", desc = "Broaden pinned code" },
    { "<leader>p>", "<cmd>TPShrink<cr>", desc = "Narrow pinned code" },
  }
}
