return {
  "gabrielpoca/replacer.nvim",
  keys = {
    { '<leader>R', '<cmd>lua require("replacer").run()<cr>', silent = true,
      desc = "run Replacer on quickfix window" },
  },
}
