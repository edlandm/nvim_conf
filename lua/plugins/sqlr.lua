local mappings = require 'config.mappings'

local map      = mappings.to_lazy
local operator = mappings.operator
local visual   = mappings.visual
local lua      = mappings.lua
local cmd      = mappings.cmd
local ll       = mappings.lleader

return {
  'edlandm/sqlr.nvim',
  ft = 'sql',
  opts = {
    viewer = 'csvview',
  },
  keys = map { ft = 'sql',
    { 'SQLR: Select Env',          ll 'se', lua "require('sqlr').pick_env()" },
    { 'SQLR: Select DB',           ll 'sd', lua "require('sqlr').pick_db()" },
    { 'SQLR: Server Restart',      ll 'sr', cmd "SqlrRestartServer" },
    { 'SQLR: Show Query Results',  ll 'R',  lua "require('sqlr').toggle_results('csvview')" },
    { 'SQLR: Show Query Messages', ll 'M',  lua "require('sqlr').toggle_results('messages')" },
    { 'SQLR: Exec <buf>',          ll 'eb', function() require('sqlr').exec(0, -1) end },
    { 'SQLR: Run <buf>',           ll 'rb', function() require('sqlr').run(0, -1) end },
    { 'SQLR: Exec <motion>',       ll 'e',
      function()
        operator(function(range)
          require('sqlr').exec(nil, unpack(range))
        end, { jump = 'origin' })
      end
    },
    { 'SQLR: Run <motion>', ll 'r',
      function()
        operator(function(range)
          require('sqlr').run(nil, unpack(range))
        end, { jump = 'origin' })
      end
    },
    { 'SQLR: Exec <selection>', ll 'e', function()
      visual(function(range)
        require('sqlr').exec(nil, unpack(range))
      end)
    end, mode = 'x' },
    { 'SQLR: Run <selection>',  ll 'r', function()
      visual(function(range)
        require('sqlr').run(nil, unpack(range))
      end)
    end, mode = 'x' },
  }
}
