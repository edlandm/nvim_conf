vim.api.nvim_buf_set_keymap(0, 'n', 'q', '', {
  desc     = 'Close quickfix list',
  noremap  = true,
  silent   = true,
  callback = function() vim.cmd 'cclose' end,
})
