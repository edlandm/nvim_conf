vim.bo.makeprg    = "go"
vim.bo.expandtab  = false
vim.bo.shiftwidth = 4
vim.bo.tabstop    = 4
vim.wo.foldmethod = "indent"

-- {{{ mappings
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
-- }}}
