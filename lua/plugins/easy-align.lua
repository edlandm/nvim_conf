return {
  "junegunn/vim-easy-align",
  event = "VimEnter",
  config = function()
    vim.g.easy_align_delimiters = {
      ["["] = {
        pattern       = '[[\\]]',
        left_margin   = 0,
        right_margin  = 0,
        stick_to_left = 0,
      },
      ["("] = {
        pattern       = "[()]",
        left_margin   = 0,
        right_margin  = 0,
        stick_to_left = 0,
      },
    }
  end,
  cmd = {
    "EasyAlign",
  },
  keys = {
    {"gl", "<Plug>(EasyAlign)", mode = {"n", "v"}, desc = "EasyAlign", },
  },
}
