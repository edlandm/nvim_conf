local mappings = require 'mappings'
local map, cmd = mappings.to_lazy, mappings.cmd
local pref     = mappings.prefix('g/')
return {
  'MagicDuck/grug-far.nvim',
  opts = {},
  init = function()
    require 'which-key'.add { pref(), group = 'GrugFar (search)', mode = { 'n', 'x' } }
  end,
  keys = map {
    { 'Grug-Far',                     pref '/', cmd 'GrugFar ripgrep' },
    { 'Grug-Far (AST-Grep)',          pref 't', cmd 'GrugFar astgrep' },
    { 'Grug-Far <visual>',            pref '/', cmd 'GrugFarWithin ripgrep', { 'x' } },
    { 'Grug-Far <visual> (AST-Grep)', pref 't', cmd 'GrugFarWithin astgrep', { 'x' } },
  },
}
