return {
  "folke/which-key.nvim",
  event = "UIEnter",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  opts = {
    triggers_blacklist = {
      i = { "h", ";", "<", ">"},
    }
  }
}
