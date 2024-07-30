-- find, sub, and abbreviate variations of words
return {
  'tpope/vim-abolish',
  lazy = false,
  ft = {'gitcommit', 'markdown', 'text', 'norg'},
  config = function()
    -- abbreviations go here
    vim.cmd({ cmd = "Abolish", args = { "deploymenst", "deployments" } })
    vim.cmd({ cmd = "Abolish", args = { "alais{,es}", "alias{,es}" } })
  end
}
