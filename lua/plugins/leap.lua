return {
  'ggandor/leap.nvim',
  keys = {
    { "-", "<Plug>(leap-forward)",
      mode = { "n", "x", "o" },
      desc = "Leap forward" },
    { "g-", "<Plug>(leap-forward)",
      mode = { "n", "x", "o" },
      desc = "Leap forward (cross-window)" },
    { "_", "<Plug>(leap-backward)",
      mode = { "n", "x", "o" },
      desc = "Leap backward" },
  },
}
