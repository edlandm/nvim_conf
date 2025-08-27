return {
  "olimorris/codecompanion.nvim",
  event = 'VeryLazy',
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    strategies = {
      chat = {
        adapter = "anthropic",
      },
      inline = {
        adapter = "anthropic",
      },
    },
    adapters = {
      http = {
        anthropic = function()
          return require('codecompanion.adapters').extend('anthropic', {
            env = {
              api_key = 'cmd:cat ' .. vim.fn.expand('~/.local/claud.api.key')
            },
          })
        end,
      },
    },
  },
  specs = {
    {
      'folke/which-key.nvim',
      opts = {
        spec = {
          { '<tab>a',  group = 'AI' },
          { '<tab>aa', '<cmd>CodeCompanionActions<cr>',     desc = 'Action Palette',                          mode = { 'n', 'v' } },
          { '<tab>ac', '<cmd>CodeCompanionChat Toggle<cr>', desc = 'Toggle Chat Buffer' },
          { '<tab>ap', ':CodeCompanion ',                   desc = 'Prompt' },
          { '<tab>ab', ':CodeCompanion /buffer ',           desc = 'Prompt +include buffer' },
          -- visual
          { '<tab>ab', ':CodeCompanionChat Add<cr>',        desc = 'Add <selection> to chat buffer',          mode = 'v' },
          { '<tab>ae', ':CodeCompanion /explain<cr>',       desc = 'Explain <selection>',                     mode = 'v' },
          { '<tab>af', ':CodeCompanion /fix<cr>',           desc = 'Fix <selection>',                         mode = 'v' },
          { '<tab>al', ':CodeCompanion /lsp<cr>',           desc = 'Explain LSP Diagnostics for <selection>', mode = 'v' },
          { '<tab>at', ':CodeCompanion /tests<cr>',         desc = 'Generate Unit Tests for <selection>',     mode = 'v' },
        },
      },
    }
  },
}
