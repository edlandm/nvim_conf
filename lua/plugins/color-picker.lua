return {
  "ziontee113/color-picker.nvim",
  config = true,
  cmd = {
    "PickColor",
    "PickColorInsert",
  },
  keys = {
    { "<leader>#", "<cmd>PickColor<cr>", silent = true },
    { ";#", "<cmd>PickColorInsert<cr>", mode = "i", silent = true },
  },
}
