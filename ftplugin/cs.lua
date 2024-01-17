-- vim:fdm=marker
vim.o.foldmethod = "indent"
vim.bo.tabstop = 4
vim.bo.shiftwidth = 4

local find_cw_references = function() -- {{{ search project for cword
  local cword = vim.fn.expand("<cword>")
  -- TODO: create function to find project/solution root and use that as basis
  -- for search glob
  vim.cmd.vimgrep({"/" .. cword .. "/j", "**/*.cs" })
  vim.cmd.copen()
end -- }}}

-- mappings
local mapopts = function(desc, opts) -- {{{ shorthand for adding the description
  _t = {buffer = true, noremap = true, desc = desc}
  if opts then
    for k,v in pairs(opts) do
      _t[k] = v
    end
  end
  return _t
end -- }}}

-- {{{ NORMAL
-- vim.keymap.set("n", "", "", mapopts(""))
vim.keymap.set("n", "<localleader>/", find_cw_references, mapopts("search project for <cword> (results in quickfix)"))
-- }}}
