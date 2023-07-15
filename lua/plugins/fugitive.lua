return {
  'tpope/vim-fugitive',
  lazy = false,
  keys = {
    { '<leader>gs', '<cmd>Git<cr>', desc = 'Git status' },
    { '<leader>gd', '<cmd>Gvdiffsplit!<cr>', desc = 'Git diff' },
  }
}
