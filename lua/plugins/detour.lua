return {
  "carbon-steel/detour.nvim",
  cmd = {
    "Detour",
    "DetourCurrentWindow",
  },
  keys = {
    {'<c-w><enter>', "<cmd>Detour<cr>"},
    {'<c-w>.', "<cmd>DetourCurrentWindow<cr>"},
  },
}
