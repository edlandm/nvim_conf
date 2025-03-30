return {
  "rachartier/tiny-inline-diagnostic.nvim",
  lazy = false,
  enabled = false,
  init = function()
    vim.diagnostic.config({ virtual_text = false })
  end,
  opts = {
    options = {
      use_icons_from_diagnostic = true,
      add_messages = true,
      multiple_diag_under_cursor = true,
      show_all_diags_on_cursorline = true,
      multilines = {
        -- Enable multiline diagnostic messages
        enabled = true,
        -- Always show messages on all lines for multiline diagnostics
        always_show = true,
      },
    },
    disabled_ft = {},
  },
  keys = {
    { '<leader>od', '<cmd>lua require("tiny-inline-diagnostic").toggle()<cr>',
      desc = 'Toggle Inline Diagnostics' -- sometimes I need some goddamn peace and quiet
    }
  },
}
