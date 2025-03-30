return {
  'AgusDOLARD/backout.nvim',
  opts = {},
  keys = {
    { '<M-l>', '<cmd>lua require("backout").back()<cr>', mode = { 'i', 'c' }, desc = 'Backout Back' },
    { '<M-d>', '<cmd>lua require("backout").out()<cr>' , mode = { 'i', 'c' }, desc = 'Backout Out'},
  },
}
