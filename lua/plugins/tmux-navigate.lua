-- navigate tmux panes and vim windows seamlessly
return {
 'alexghergh/nvim-tmux-navigation',
  lazy = false,
  priority = 999,
  opts = {}, -- for some reason this must be populated, even if empty
  keys = {
    { "<c-h>", "<cmd>NvimTmuxNavigateLeft<cr>",
        silent = true, desc = "Switch to window/pane left" },
    { "<c-j>", "<cmd>NvimTmuxNavigateDown<cr>",
        silent = true, desc = "Switch to window/pane down" },
    { "<c-k>", "<cmd>NvimTmuxNavigateUp<cr>",
        silent = true, desc = "Switch to window/pane up" },
    { "<c-l>", "<cmd>NvimTmuxNavigateRight<cr>",
        silent = true, desc = "Switch to window/pane right" },
    },
}
