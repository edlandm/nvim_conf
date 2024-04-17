return {
  'jcdickinson/codeium.nvim',
  lazy = false,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'hrsh7th/nvim-cmp',
  },
  opts = {
    config_path = vim.fn.expand("~/.local/codeium.conf"),
    enable_chat = true,
  },
}
