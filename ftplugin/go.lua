vim.bo.makeprg = "go"
vim.bo.expandtab = false
-- {{{ mappings
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
vim.keymap.set("n", "<localleader>t", "<cmd>make! test %:p:h<cr>", mapopts("run tests for the current file's directory")) -- }}}
-- }}}
