return {
  'dwrdx/mywords.nvim',
  keys = {
    { '<leader>h', '<cmd>lua require("mywords").hl_toggle()<cr>',
      desc = 'Highlight word', silent = true },
    { '<leader>H', '<cmd>lua require("mywords").uhl_all()<cr>',
      desc = 'Clear word highlights', silent = true },
  }
}
