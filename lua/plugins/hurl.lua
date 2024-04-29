local function setmaps()
  local function map(mode, lhs, rhs, desc)
    vim.api.nvim_buf_set_keymap(0, mode, lhs, rhs, { desc = desc })
  end

  local function nmap(lhs, rhs, desc)
    map("n", lhs, rhs, desc)
  end

  local function vmap(lhs, rhs, desc)
    map("v", lhs, rhs, desc)
  end

  -- execute code
  nmap("<F5>", "<cmd>HurlRunner<cr>", "Hurl: execute file")
  nmap("<localleader>ef", "<cmd>HurlRunner<cr>", "Hurl: [e]xecute [f]ile")
  nmap("<localleader>er", "<cmd>HurlRunnerAt<cr>", "Hurl: [e]xecute [r]equest")
  nmap("<localleader>et", "<cmd>HurlRunnerToEntry<cr>", "Hurl: [e]xecute up [t]o request")
  nmap("<localleader>e<cr>", "<cmd>HurlShowLastResponse<cr>", "Hurl: show last response")

  -- environment variables
  nmap("<localleader>he", ":HurlSetVariable ", "Hurl: Set [e]nvironment variable")
  -- NOTE: for now this buffer is only for viewing variables, but modifying is on the roadmap
  nmap("<localleader>hV", "<cmd>HurlManageVariable<cr>", "Hurl: View environment [V]ariables")
  -- NOTE: can be comma-separated list
  nmap("<localleader>hf", ":HurlSetEnvFile ", "Hurl: Set environment [f]ile")

  -- modes
  nmap("<localleader>hs", "<cmd>HurlToggleMode<cr>", "Hurl: Toggle popup/[s]plit mode")
  nmap("<localleader>hv", "<cmd>HurlToggleMode<cr>", "Hurl: Toggle [v]erbose mode")

  -- Visual Mappings
  vmap("<F5>", ":HurlRunner<cr>", "Hurl: Run selection")
  vmap("<localleader>e", ":HurlRunner<cr>", "Hurl: Run selection")
end

return {
  "jellydn/hurl.nvim",
  dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter"
  },
  ft = "hurl",
  opts = {
    -- Show debugging info
    debug = false,
    -- Show notification on run
    show_notification = false,
    -- Show response in popup or split
    mode = "popup",
    -- Default formatter
    formatters = {
      json = { 'jq' }, -- Make sure you have install jq in your system, e.g: apt install jq
      html = {
        'prettier', -- Make sure you have install prettier in your system, e.g: npm install -g prettier
        '--parser',
        'html',
      },
    },
  },
  config = function (opts)
    require('hurl').setup(opts)

    local groupid = vim.api.nvim_create_augroup("HURL", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "BufNewFile" }, { pattern = "*.hurl", group = groupid, callback = setmaps })
    vim.api.nvim_create_autocmd("FileType", { pattern = "hurl", group = groupid, callback = setmaps })
  end,
}
