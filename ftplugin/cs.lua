require('settings').setopts('o', {
  { 'foldmethod', 'indent' }
})

require('settings').setopts('bo', {
  { 'tabstop', 4 },
  { 'shiftwidth', 4 },
  { 'makeprg', 'dotnet build' },
})

require('mappings').nmap({
  { 'Start Debugger', '<F5>', '<cmd>lua require("dap").continue()<cr>' }
}, true)
