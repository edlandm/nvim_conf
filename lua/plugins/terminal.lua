local mappings = require 'config.mappings'
local lua, map = mappings.lua, mappings.to_lazy
local pref     = mappings.prefix('<leader>t')

local function term(fn, args)
  return lua('require("betterTerm").%s(%s)')
    :format(assert(fn, 'fn required'), args or '')
end

return {
  {
    'CRAG666/betterTerm.nvim',
    lazy = false,
    -- events = 'VeryLazy',
    opts = {
      jump_tab_mapping = "<A-$tab>", -- Alt+1 , Alt+2, ...
      startInserted = false,
    },
    init = function()
      require 'config.mappings'.tmap({
        { 'Normal Mode', '<esc><esc>', '<c-\\><c-n>' },
        { 'Normal Mode', 'hs',         '<c-\\><c-n>' },
        -- { 'Switch Window Up',    '<c-k>',      '<c-\\><c-n><c-w>k' },
        -- { 'Switch Window Down',  '<c-j>',      '<c-\\><c-n><c-w>j' },
        -- { 'Switch Window Left',  '<c-h>',      '<c-\\><c-n><c-w>h' },
        -- { 'Switch Window Right', '<c-l>',      '<c-\\><c-n><c-w>l' },
        { 'Kill terminal process', '<a-d><a-d><a-d>', '<cmd>lua vim.fn.jobstop(vim.bo[vim.api.nvim_get_current_buf()].channel)<cr>' },
      })
    end,
    keys = map {
      { 'Open Terminal',   pref 't', term 'open', { 'n', 't' } },
      { 'Select Terminal', pref 's', term 'select' },
      unpack(vim.tbl_map(
        function(i)
          return {
            ('Open Term %d'):format(i),
            pref(i),
            term('open', i)
          }
        end,
        { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 }))
    },
  },
  {
    "chomosuke/term-edit.nvim",
    lazy = false,
    opts = {
      prompt_end = '^.-%d%d:%d%d  ',
    }
  }
}
