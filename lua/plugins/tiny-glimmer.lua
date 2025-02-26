return {
  'rachartier/tiny-glimmer.nvim',
  enabled = true,
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
  keys = {
    { 'n', function()
      vim.fn.search(vim.fn.getreg("/"), 'w')
      require('tiny-glimmer').search_next()
    end, desc = 'Search Forward (glimmer)' },
    { 'N', function()
      vim.fn.search(vim.fn.getreg("/"), 'wb')
      require('tiny-glimmer').search_prev()
    end, desc = 'Search Backward' },
  },
}
