vim.bo.tabstop = 2
vim.bo.shiftwidth = 2
vim.g.markdown_folding = 1

-- this is counting on dial.nvim plugin to work correctly
vim.keymap.set('i', '<c-a>',     '<c-o><c-a>',     { desc = 'increase checkbox state', buffer = true, remap = true })
vim.keymap.set('i', '<c-x>',     '<c-o><c-x>',     { desc = 'decrease checkbox state', buffer = true, remap = true })
