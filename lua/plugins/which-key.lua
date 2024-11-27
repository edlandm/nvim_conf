return {
  "folke/which-key.nvim",
  event = 'VeryLazy',
  opts = {},
  keys = {
    {
      "<localleader><localleader>",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
    {
      "<leader><leader>",
      function()
        require("which-key").show({ global = true })
      end,
      desc = "Global Keymaps (which-key)",
    },
  },
}
