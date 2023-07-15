return {
  'nvim-neorg/neorg',
  opts = {
    load = {
      ['core.defaults'] = {},
      ['core.concealer'] = {},
      ['core.export'] = {},
      ['core.itero'] = {},
      ['core.presenter'] = {
        config = {
          zen_mode = "zen-mode",
        }
      },
      -- ['core.ui.calendar'] = {},
      ['core.keybinds'] = {
        config = {
          hook = function(keybinds)
            keybinds.remap_key("norg", "i", "<M-CR>", ";n")
          end,
        }
      }
    },
  },
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
  },
  ft = 'norg',
  keys = {
    { "<c-r><c-l>", "{<c-r><c-+>}[]<left>", { desc = "paste link from system clipboard" }},
  }
}
