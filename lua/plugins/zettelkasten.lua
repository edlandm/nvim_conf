-- zettelkasten note-taking system
return {
  'Furkanzmc/zettelkasten.nvim',
  cmd = {
    'ZkBrowse',
    'ZkNew',
  },
  opts = {
    notes_path = vim.fn.stdpath('data') .. '/zettelkasten',
  }
}
