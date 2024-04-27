return {
  "tamton-aquib/duck.nvim",
  event = "VimEnter",
  config = function()
    vim.keymap.set('n', '<leader>dd', function() require("duck").hatch() end, {})
    vim.keymap.set('n', '<leader>dx', function() require("duck").cook_all() end, {})
  end
}
