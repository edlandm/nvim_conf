require 'config.settings'.setopts('o', {
  { 'foldmethod', 'indent' }
})

require 'config.settings'.setopts('bo', {
  { 'tabstop', 4 },
  { 'shiftwidth', 4 },
  { 'makeprg', 'dotnet build' },
})

require 'config.mappings'.nmap({
  { 'Start Debugger', '<F5>', '<cmd>lua require("dap").continue()<cr>' }
}, true)
