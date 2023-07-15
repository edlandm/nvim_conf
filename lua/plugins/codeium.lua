return {
  'jcdickinson/codeium.nvim',
  lazy = false,
  -- pinning to this commit because neovim hasn't implemented
  -- vim.fn.inputsecret yet and it's causing an error when authenticating
  commit = "b1ff0d6c993e3d87a4362d2ccd6c660f7444599f",
  dependencies = {
    'nvim-lua/plenary.nvim',
    'hrsh7th/nvim-cmp',
  },
  opts = {
    config_path = vim.fn.expand("~/.local/codeium.conf")
  },
}
