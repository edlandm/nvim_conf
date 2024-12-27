return {
  "folke/which-key.nvim",
  event = 'VeryLazy',
  opts = {
    defer = function(ctx)
      if ctx.mode == "V" or ctx.mode == "<C-V>" then
        return true
      end

      if vim.list_contains({ "d", "y" }, ctx.operator) then
        return true
      end
    end,
  },
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
