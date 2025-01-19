local cmd = require('mappings').cmd
local prefix = function(s) return ('<leader>t%s'):format(s) end
return {
  'Hashino/doing.nvim',
  opts = {
    winbar = { enabled = false },
  },
  cmd = {
    'Do'
  },
  keys = { -- prefix: <leader>d
    { prefix('a'), ':Do add ', desc = 'Doing [A]dd (end of list)' },
    { prefix('A'), ':Do! add ', desc = 'Doing [A]dd (front of list)' },
    { prefix('t'), cmd 'Do status', desc = 'Doing show [T]ask' },
    { prefix('T'), cmd 'Do toggle', desc = 'Doing [T]oggle' },
    { prefix('d'), cmd 'Do done', desc = 'Doing [D]one' },
    { prefix('e'), cmd 'Do edit', desc = 'Doing [E]dit tasklist' },
  },
}
