-- find, sub, and abbreviate variations of words
return {
  'tpope/vim-abolish',
  lazy = false,
  ft = {'gitcommit', 'markdown', 'text', 'norg'},
  init = function ()
    -- I decided to use gregorias/coerce.nvim for the coerce functionality
    vim.g.abolish_no_mappings = true
  end,
  config = function()
    -- abbreviations go here
    vim.cmd({ cmd = "Abolish", args = { "deploymenst", "deployments" } })
    vim.cmd({ cmd = "Abolish", args = { "alais{,es}", "alias{,es}" } })
  end
}
