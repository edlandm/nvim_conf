vim.bo.tabstop    = 2
vim.bo.shiftwidth = 2
vim.bo.makeprg    = 'dune'
vim.wo.foldmethod = 'indent'

vim.api.nvim_buf_set_keymap(0, 'n', '<F5>', '<cmd>make build<cr>', { desc = 'build project' })
vim.api.nvim_buf_set_keymap(0, 'n', '<F4>', '<cmd>make test<cr>', { desc = 'run tests' })
