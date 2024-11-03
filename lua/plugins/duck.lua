return {
  "tamton-aquib/duck.nvim",
  event = "VimEnter",
  config = function()
    vim.keymap.set('n', '<leader>dd', function() require("duck").hatch() end, { desc = 'definitally not a duck' })
    vim.keymap.set('n', '<leader>dx', function() require("duck").cook_all() end, { desc = 'duck season' })
  end
}
