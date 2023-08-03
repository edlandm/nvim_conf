return {
  "ibhagwan/fzf-lua",
  lazy = false,
  -- optional for icon support
  register_ui_select = true,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = { "max-perf" },
  keys = {
    { "<c-p>", "<cmd>lua require('fzf-lua').files()<cr>", },
    { "<tab>", "<cmd>lua require('fzf-lua').buffers()<cr>", },
    { "<leader>/,", "<cmd>lua require('fzf-lua').lines()<cr>",
      desc = "FZF: lines in open buffers"},
    { "<leader>/.", "<cmd>lua require('fzf-lua').blines()<cr>",
      desc = "FZF: lines in current buffer"},
    { "<leader>/a", "<cmd>lua require('fzf-lua').autocmds()<cr>",
      desc = "FZF: autocommands"},
    { "<leader>/c", "<cmd>lua require('fzf-lua').colorschemes()<cr>",
      desc = "FZF: colorschemes"},
    { "<leader>/q", "<cmd>lua require('fzf-lua').quickfix()<cr>",
      desc = "FZF: quickfix list"},
    { "<leader>/l", "<cmd>lua require('fzf-lua').loclist()<cr>",
      desc = "FZF: location list"},
    { "<leader>//", "<cmd>lua require('fzf-lua').grep()<cr>",
      desc = "FZF: search files with grep or ripgrep"},
    { "<leader>/g,", "<cmd>lua require('fzf-lua').git_commits()<cr>",
      desc = "FZF: git commit log"},
    { "<leader>/g.", "<cmd>lua require('fzf-lua').git_bcommits()<cr>",
      desc = "FZF: git commits for current buffer"},
    { "<leader>/gg", "<cmd>lua require('fzf-lua').git_files()<cr>",
      desc = "FZF: files in git repository"},
    { "<leader>/gs", "<cmd>lua require('fzf-lua').git_status()<cr>",
      desc = "FZF: git status"},
    { "<leader>/hh", "<cmd>lua require('fzf-lua').help_tags()<cr>",
      desc = "FZF: neovim help"},
    { "<leader>/hi", "<cmd>lua require('fzf-lua').highlights()<cr>",
      desc = "FZF: highlight groups"},
    { "<leader>/j", "<cmd>lua require('fzf-lua').jumps()<cr>",
      desc = "FZF: jumps"},
    { "<leader>/k", "<cmd>lua require('fzf-lua').keymaps()<cr>",
      desc = "FZF: keymaps"},
    { "<leader>/m", "<cmd>lua require('fzf-lua').marks()<cr>",
      desc = "FZF: marks"},
    { "<leader>/M", "<cmd>lua require('fzf-lua').man_pages()<cr>",
      desc = "FZF: man pages"},
    { "<leader>/r", "<cmd>lua require('fzf-lua').registers()<cr>",
      desc = "FZF: registers"},
    { "<leader>/t", "<cmd>lua require('fzf-lua').tags()<cr>",
      desc = "FZF: tags"},
    { "<leader>/z", "<cmd>lua require('fzf-lua').spell_suggest()<cr>",
      desc = "FZF: spelling suggestions"},
    { "<leader>/?", "<cmd>lua require('fzf-lua').search_history()<cr>",
      desc = "FZF: search history"},
    { "<leader>/:", "<cmd>lua require('fzf-lua').command_history()<cr>",
      desc = "FZF: command history"},
  }
}