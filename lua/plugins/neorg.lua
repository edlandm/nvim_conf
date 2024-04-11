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
          hook = function(keybinds)
            keybinds.unmap("all", "n", "gO") -- originally mapped to open table-of-contents
            keybinds.unmap("all", "n", "go") -- originally mapped to open table-of-contents

            keybinds.remap_key("norg", "i", "<M-CR>", ";n",
              { desc = "start new list entry" })

            keybinds.map("norg", "n", "<localleader>ec",
              "<cmd>Neorg keybind all core.looking-glass.magnify-code-block<cr>",
              { desc = "edit code-block in new buffer"})

            keybinds.map("norg", "n", "<localleader><leader>", "<cmd>Neorg toc qflist<cr>",
              { desc = "open table-of-contents in quickfix list"})

            keybinds.remap("norg", "n", "<localleader><cr>",
              "<cmd>Neorg keybind all core.esupports.hop.hop-link vsplit<cr>",
              { desc = "Jump to Link (Vertical Split)" })

            keybinds.map("norg", "n", "<localleader>tc", function()
              local cc = vim.wo.concealcursor
              if cc == "" then
                vim.wo.concealcursor = "nc"
              else
                vim.wo.concealcursor = ""
              end
              end,
              { desc = "toggle" })
          end,
        }
      },
      ['core.journal'] = {
        config = {
          strategy = "flat",
        }
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
