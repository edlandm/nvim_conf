return {
  'ThePrimeagen/harpoon',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  opts = {
    global_settings = {
      enter_on_sendcmd = true,
    }
  },
  keys = {
    { '<leader>h,', '<cmd>lua require("harpoon.ui").toggle_quick_menu()<cr>',
      desc = 'Harpoon: Toggle quick menu' },
    { '<leader>h.', '<cmd>lua require("harpoon.mark").add_file()<cr>',
      desc = 'Harpoon: Add file' },
    { '<leader>ha', '<cmd>lua require("harpoon.ui").nav_file(1)<cr>',
      desc = 'Harpoon: Jump to file 1' },
    { '<leader>ho', '<cmd>lua require("harpoon.ui").nav_file(2)<cr>',
      desc = 'Harpoon: Jump to file 2' },
    { '<leader>he', '<cmd>lua require("harpoon.ui").nav_file(3)<cr>',
      desc = 'Harpoon: Jump to file 3' },
    { '<leader>hu', '<cmd>lua require("harpoon.ui").nav_file(4)<cr>',
      desc = 'Harpoon: Jump to file 4' },
    { '<leader>hc', '<cmd>lua require("harpoon.term").gotoTerminal(1)<cr>',
      desc = 'Harpoon: Go to Terminal 1' },
    { '<leader>hC', '<cmd>lua require("harpoon.cmd-ui").toggle_quick_menu()<cr>',
      desc = 'Harpoon: Toggle Command quick menu' },
    { '<leader>hh', '<cmd>lua require("harpoon.term").sendCommand(1, 1)<cr>',
      desc = 'Harpoon: Send command 1 to terminal 1' },
    { '<leader>ht', '<cmd>lua require("harpoon.term").sendCommand(1, 2)<cr>',
      desc = 'Harpoon: Send command 2 to terminal 1' },
    { '<leader>hn', '<cmd>lua require("harpoon.term").sendCommand(1, 3)<cr>',
      desc = 'Harpoon: Send command 3 to terminal 1' },
    { '<leader>hs', '<cmd>lua require("harpoon.term").sendCommand(1, 4)<cr>',
      desc = 'Harpoon: Send command 4 to terminal 1' },
  }
}
