return {
  "rachartier/tiny-inline-diagnostic.nvim",
  lazy = false,
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
}
