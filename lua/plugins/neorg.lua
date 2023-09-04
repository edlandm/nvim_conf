return {
  'nvim-neorg/neorg',
  opts = {
    load = {
      ['core.defaults'] = {},
      ['core.concealer'] = {},
      ['core.export'] = {},
      ['core.itero'] = {},
      ['core.completion'] = {
        config = {
          engine = "nvim-cmp",
        }
      },
      ['core.presenter'] = {
        config = {
          zen_mode = "zen-mode",
        }
      },
      -- ['core.ui.calendar'] = {},
      ['core.keybinds'] = {
        config = {
          hook = function(keybinds)
            keybinds.unmap("all", "n", "gO") -- originally mapped to open table-of-contents
            keybinds.unmap("all", "n", "go") -- originally mapped to open table-of-contents

            keybinds.remap_key("norg", "i", "<M-CR>", ";n",
              { desc = "start new list entry" })

            keybinds.map("norg", "n", "<localleader>ec",
              "<cmd>Neorg keybind all core.looking-glass.magnify-code-block<cr>",
              { desc = "edit code-block"})
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
