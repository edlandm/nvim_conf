return {
  'rachartier/tiny-glimmer.nvim',
  pin = true,
  event = 'VeryLazy',
  init = function()
    vim.api.nvim_del_keymap('n', 'n')
    vim.api.nvim_del_keymap('n', 'N')
  end,
  opts = {
    enabled = true,
    overwrite = {
      auto_map = true,
      search = {
        enabled = true,
        default_animation = "pulse",
        next_mapping = function()
          local keys = { 'N', 'n' }
          return keys[(vim.v.searchforward+1)] .. 'zzzv'
        end,
        prev_mapping = function()
          local keys = { 'n', 'N' }
          return keys[(vim.v.searchforward+1)] .. 'zzzv'
        end,
      },
      paste = {
        enabled = true,
        default_animation = "reverse_fade",
        -- Keys to paste
        -- Can also be a function that returns a string
        paste_mapping = "p",
        Paste_mapping = "P",
      },
    },
    default_animation = 'fade',
    animations = {
      fade = {
        max_duration = 250,
        chars_for_max_duration = 20,
      },
      pulse = {
        max_duration = 150,
        chars_for_max_duration = 10,
      },
    }
  },
  -- keys = {
  --   { 'n', function()
  --     local g = require('tiny-glimmer')
  --     if vim.v.searchforward == 1 then
  --       g.search_next()
  --     else
  --       g.search_prev()
  --     end
  --   end, desc = 'Search Forward (glimmer)' },
  --   { 'N', function()
  --     local g = require('tiny-glimmer')
  --     if vim.v.searchforward == 0 then
  --       g.search_next()
  --     else
  --       g.search_prev()
  --     end
  --   end, desc = 'Search Backward' },
  -- },
}
