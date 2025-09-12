return {
  dir = vim.fs.joinpath(vim.fn.stdpath('config'), 'plugin', 'resize'),
  name = 'resize',
  event = 'VeryLazy',
  dependencies = {
    'debugloop/layers.nvim',
  },
  opts = {},
  keys = {
    { '<c-w><c-r>', '<Plug>(ResizeMode)', { desc = 'Resize Mode' }},
  },
}
