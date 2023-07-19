return {
  'tpope/vim-fugitive',
  keys = {
    { '<leader>gs', '<cmd>Git<cr>', desc = 'Git status' },
    { '<leader>gd', '<cmd>Gvdiffsplit!<cr>', desc = 'Git diff' },
    -- TODO: allow user to provide the branch to check against
    { '<leader>gn', '<cmd>Git log --oneline --cherry develop..HEAD<cr>', desc = 'List commits from the current branch' },
  },
  cmd = {
    "Git",
    "Gvdiffsplit",
  },
}
