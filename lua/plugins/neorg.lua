return {
  'nvim-neorg/neorg',
  lazy = false,
  opts = {
    load = {
      ['core.defaults'] = {},
      ['core.concealer'] = {},
      ['core.export'] = {},
      ['core.itero'] = {},
      ['core.dirman'] = {
        config = {
          workspaces = {
            nvim = "~/.config/nvim",
          },
        },
      },
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
          default_keybinds = false,
        }
      },
      ['core.journal'] = {
        config = {
          strategy = "flat",
        }
      },
      ['core.qol.todo_items'] = {
        create_todo_items = true,
        create_todo_parents = false,
      },
    },
  },
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'vhyrro/luarocks.nvim',
  },
  version = "*",
  config = true,
}
