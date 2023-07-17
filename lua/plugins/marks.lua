return {
  "chentoast/marks.nvim",
  lazy = false,
  opts = {
    builtin_marks = { ".", "<", ">", "^" },
    refresh_interval = 250,
    sign_priority = { lower=10, upper=15, builtin=8, bookmark=20 },
  },
}
