return {
  "Hajime-Suzuki/vuffers.nvim",
  lazy = false,
  dependencies = {
    "Tastyep/structlog.nvim",
  },
  config = function()
    require("vuffers").setup({
      debug = {
        enabled = true,
        level = "error",
      },
      exclude = {
        filenames = {
          "term://"
        },
        filetypes = {
          "lazygit",
        },
      },
      keymaps = {
        use_default = true,
      },
      view = {
        window = {
          focus_on_open = true,
        },
      },
      handlers = {
        on_delete_buffer = function(bufnr)
          vim.api.nvim_command(":bwipeout! " .. bufnr)
        end
      },
    })
  end,
  keys = {
    {"<tab>", function() require("vuffers").toggle() end,
      desc = "toggle Vuffers sidebar"}
  },
}
