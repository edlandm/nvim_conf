local mappings = require 'config.mappings'
local map      = mappings.to_lazy
local ll       = mappings.lleader

return {
  dir = vim.fs.joinpath(vim.fn.stdpath('config'), 'plugin', 'sql.nvim'),
  name = 'sql',
  ft = 'sql',
  opts = {},
  keys = map { ft = 'sql',
    {'SQL: Expand Where/Join Predicates', ll 'ew', '<Plug>(SqlExpandWhere)', mode = 'n' },
    {'SQL: Expand Where/Join Predicates', '<M-W>', '<Plug>(SqlExpandWhere)', mode = 'i' },
    {'SQL: Expand Where/Join Predicates', ll 'ew', '<Plug>(SqlExpandWhere)', mode = 'x' },
    {'SQL: Fix Commas',                   ll 'fc', '<Plug>(SqlFixCommas)',   mode = 'x' },
    -- { 'SQL: ', '', '<Plug>(SQL)' },
  },
}
