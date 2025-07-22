vim.bo.shiftwidth = 2
vim.bo.tabstop    = 2
vim.wo.foldmethod = "indent"

vim.bo.makeprg = 'lua'

require 'config.mappings'.nmap({
  { 'execute current file with :make', '<F5>', '<cmd>make %<cr>'  },
}, true)
