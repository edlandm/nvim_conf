local function setmaps()
  require 'config.mappings'.map {
    { mode = 'n', buffer = true,
      -- execute code
      { "Hurl: execute buffer", "<F5>", "<cmd>%HurlRunner<cr>" },
      { "Hurl: execute buffer", "<localleader>eb", "<cmd>%HurlRunner<cr>" },
      { "Hurl: [e]xecute [f]ile", "<localleader>ef", "<cmd>HurlRunner<cr>" },
      { "Hurl: [e]xecute [r]equest", "<localleader>er", "vip:HurlRunner<cr>" },
      { "Hurl: [e]xecute up [t]o request", "<localleader>et",
        function ()
          vim.cmd.normal('vip')
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), 'itx', false)

          vim.api.nvim_buf_set_mark(0, '<', 1, 0, {})
          local endline = vim.api.nvim_buf_get_mark(0, '>')[1]

          vim.api.nvim_cmd({ cmd = 'HurlRunner', range = {1, endline} }, {})
        end
      },
      { "Hurl: show last response", "<localleader>e<cr>", "<cmd>HurlShowLastResponse<cr>" },
      -- environment variables
      { "Hurl: Set [e]nvironment variable", "<localleader>he", ":HurlSetVariable " , { silent = false  }},
      -- NOTE: for now this buffer is only for viewing variables, but modifying is on the roadmap
      { "Hurl: View environment [V]ariables", "<localleader>hV", "<cmd>HurlManageVariable<cr>" },
      -- NOTE: can be comma-separated list
      { "Hurl: Set environment [f]ile", "<localleader>hf", ":HurlSetEnvFile ", { silent = false  }},
      -- modes
      { "Hurl: Toggle popup/[s]plit mode", "<localleader>hs", "<cmd>HurlToggleMode<cr>" },
      { "Hurl: Toggle [v]erbose mode", "<localleader>hv", "<cmd>HurlToggleMode<cr>" },
    },
    { mode = 'x', buffer = true,
      { "Hurl: Run selection", "<F5>", ":HurlRunner<cr>" },
      { "Hurl: Run selection", "<localleader>e", ":HurlRunner<cr>" },
    },
  }
end

return {
  "jellydn/hurl.nvim",
  lazy = false,
  dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter"
  },
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
  init = function()
    local groupid = vim.api.nvim_create_augroup("HURL", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "BufNewFile" }, { pattern = "*.hurl", group = groupid, callback = setmaps })
    vim.api.nvim_create_autocmd("FileType", { pattern = "hurl", group = groupid, callback = setmaps })
  end,
}
