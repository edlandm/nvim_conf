return {
  'ThePrimeagen/harpoon',
  opts = {
    global_settings = { enter_on_sendcmd = true }
  },
  keys = {
    { '<leader>ha', '<cmd>lua require("harpoon.mark").add_file()<cr>',
      desc = 'Harpoon: Add file' },
    { '<leader>h<space>', '<cmd>lua require("harpoon.ui").toggle_quick_menu()<cr>',
      desc = 'Harpoon: Toggle quick menu' },
    { '<leader>hh', '<cmd>lua require("harpoon.ui").nav_file(1)<cr>',
      desc = 'Harpoon: Jump to file 1' },
    { '<leader>ht', '<cmd>lua require("harpoon.ui").nav_file(2)<cr>',
      desc = 'Harpoon: Jump to file 2' },
    { '<leader>hn', '<cmd>lua require("harpoon.ui").nav_file(3)<cr>',
      desc = 'Harpoon: Jump to file 3' },
    { '<leader>hs', '<cmd>lua require("harpoon.ui").nav_file(4)<cr>',
      desc = 'Harpoon: Jump to file 4' },
    { '<leader>hc', '<cmd>lua require("harpoon.term").gotoTerminal(1)<cr>',
      desc = 'Harpoon: Go to Terminal 1' },
    { '<leader>hC', '<cmd>lua require("harpoon.cmd-ui").toggle_quick_menu()<cr>',
      desc = 'Harpoon: Toggle Command quick menu' },
    { '<leader hH', '<cmd>lua require("harpoon.term").sendCommand(1, 1)<cr>',
      desc = 'Harpoon: Send command 1 to terminal 1' },
    { '<leader hT', '<cmd>lua require("harpoon.term").sendCommand(2, 1)<cr>',
      desc = 'Harpoon: Send command 2 to terminal 1' },
    { '<leader hN', '<cmd>lua require("harpoon.term").sendCommand(3, 1)<cr>',
      desc = 'Harpoon: Send command 3 to terminal 1' },
    { '<leader hS', '<cmd>lua require("harpoon.term").sendCommand(4, 1)<cr>',
      desc = 'Harpoon: Send command 4 to terminal 1' },
  }
}
