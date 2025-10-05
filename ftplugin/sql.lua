-- Settings =================================================================
vim.o.shiftround     = false
vim.wo.foldmethod    = 'indent'
vim.wo.foldignore    = ''
vim.bo.expandtab     = true
vim.bo.commentstring = '--\\ %s'
vim.bo.suffixesadd   = '.sql'
vim.bo.shiftwidth    = 4
vim.bo.tabstop       = 4

-- Mappings ==================================================================
local mappings = require 'config.mappings'
mappings.map {
  { mode = 'i', buffer = true,
    { 'expand: AND',                'A<tab>',  'AND<space>' },
    { 'expand: CASE WHEN...END',    'C<tab>',  'CASE<space>WHEN<esc>o<tab>END<esc>kA<space>' },
    { 'expand: CONVERT',            'CR<tab>', 'CONVERT()<left>' },
    { 'expand: DECLARE',            'D<tab>',  'DECLARE<cr><tab>' },
    { 'expand: FROM ',              'F<tab>',  'FROM ' },
    { 'expand: GROUP BY',           'G<tab>',  'GROUP BY<cr><tab> ' },
    { 'expand: HAVING',             'H<tab>',  'HAVING<tab>' },
    { 'expand: INSERT INTO',        'I<tab>',  'INSERT<space>INTO' },
    { 'expand: LEFT OUTER JOIN ON', 'L<tab>',  'LEFT<space>OUTER<space>JOIN<space><cr>ON<tab><esc>>>kA' },
    { 'expand: INNER JOIN ON',      'N<tab>',  'INNER<space>JOIN<space><cr>ON<tab><esc>>>kA' },
    { 'expand: ORDER BY',           'O<tab>',  'ORDER<space>BY<cr><tab>' },
    { 'expand: PARTITION BY',       'P<tab>',  'PARTITION<space>BY<space>' },
    { 'expand: SELECT 1',           'SS<tab>', 'SELECT 1' },
    { 'expand: SELECT TOP 1',       'ST<tab>', 'SELECT TOP 1<cr><tab>' },
    { 'expand: SELECT',             'S<tab>',  'SELECT<cr><tab> ' },
    { 'expand: UPDATE',             'U<tab>',  'UPDATE<space><cr>SET<tab><esc>kA' },
    { 'expand: OVER ()',            'V<tab>',  'OVER<space>()<left>' },
    { 'expand: WHERE',              'W<tab>',  'WHERE<space>' },
    { 'expand: WITH (NOLOCK)',      'WN',      'WITH<space>(NOLOCK)' },
  },
}
