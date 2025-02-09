return {
  'jcdickinson/codeium.nvim',
  lazy = false,
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  opts = {
    config_path = vim.fn.expand("~/.local/codeium.conf"),
    enable_chat = true,
    virtual_text = {
      filetypes = {
        oil = false,
      }
    },
  },
}
