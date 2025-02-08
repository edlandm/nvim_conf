return {
  "mei28/luminate.nvim",
  enabled = true,
  event = "VeryLazy",
  config = function ()
    local visual   = assert(vim.api.nvim_get_hl(0, {name = "Visual"}), "Error getting visual hl group")
    local diff_add = assert(vim.api.nvim_get_hl(0, {name = "DiffAdd"}), "Error getting DiffAdd hl group")
    require('luminate').setup({
      duration = 180,
      yank = { enabled = false },
      paste = {
        enabled = false,
        map = { p = 'p', P = 'P' },
      },
      undo = {
        guibg = visual.bg,
      },
      redo = {
        guibg = diff_add.bg,
      }
    })
  end,
}
