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
    { "<leader>ss", "<cmd>Grepper<cr>", desc = "Grepper search" },
    { "<leader>SS", "<cmd>Grepper -buffers<cr>", desc = "Grepper search (open buffers)" },
    { "<leader>s",  "<plug>(GrepperOperator)", desc = "Grepper search <motion>" },
    { "<leader>S",  "<plug>(GrepperOperator -buffers)", desc = "Grepper search <motion> (open buffers)" },
    { "<leader>s*", "<cmd>Grepper -cword -noprompt<cr>", desc = "Grepper search <cword>" },
    { "<leader>s#", "<cmd>Grepper -cword -noprompt -buffer<cr>", desc = "Grepper search buffer <cword>" },
    { "<leader>s",  "<plug>(GrepperOperator)", mode = "x", desc = "Grepper search <motion>" },
  },
}
