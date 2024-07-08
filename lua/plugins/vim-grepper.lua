return {
  "mhinz/vim-grepper",
  config =function ()
    vim.g.grepper = {
      tools = { "rg", "git", "grep" },
    }
    vim.cmd(([[
        aug Grepper
            au!
            au User Grepper ++nested %s
        aug END
    ]]):format([[call setqflist([], 'r', {'context': {'bqf': {'pattern_hl': '\%#' . getreg('/')}}})]]))
  end,
  dependencies = {
    "kevinhwang91/nvim-bqf",
  },
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
