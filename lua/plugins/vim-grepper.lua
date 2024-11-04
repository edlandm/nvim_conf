return {
  "mhinz/vim-grepper",
  config =function ()
    vim.g.grepper = {
      tools = { "rg", "git", "grep" },
    }
  end,
  cmd = {
    "Grepper",
  },
  keys = {
    { "<leader>/", "<cmd>Grepper<cr>", desc = "Grepper search" },
    { "<leader>?", "<cmd>Grepper<cr>", desc = "Grepper search buffer" },
    { "g/", "<plug>(GrepperOperator)", desc = "Grepper search [motion]" },
    { "g?", "<plug>(GrepperOperator)", desc = "Grepper search buffer [motion]" },
    { "g*", "<cmd>Grepper -cword -noprompt<cr>", desc = "Grepper search [cword]" },
    { "g#", "<cmd>Grepper -cword -noprompt -buffer<cr>", desc = "Grepper search buffer [cword]" },
  },
}
