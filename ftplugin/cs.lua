-- vim:fdm=marker
vim.o.foldmethod = "indent"
vim.bo.tabstop = 4
vim.bo.shiftwidth = 4

-- mappings
local mapopts = function(desc, opts) -- {{{ shorthand for adding the description
  local _t = {buffer = true, noremap = true, desc = desc}
  if opts then
    for k,v in pairs(opts) do
      _t[k] = v
    end
  end
  return _t
end -- }}}

-- {{{ NORMAL
-- vim.keymap.set("n", "", "", mapopts(""))
-- }}}
