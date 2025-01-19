return {
  'yarospace/lua-console.nvim',
  lazy = true,
  keys = { '<leader>l' },
  opts = {
    buffer = {
      result_prefix    = '=> ',
      save_path        = vim.fn.stdpath('state') .. '/lua-console.lua',
      autosave         = true, -- autosave on console hide / close
      load_on_start    = true, -- load saved session on start
      preserve_context = true,  -- preserve results between evaluations
    },
    window = {
      border = 'double', -- single|double|rounded
      height = 0.6, -- percentage of main window
    },
    mappings = {
      toggle = '<leader>l',
      attach = '<Leader>L',
      quit = 'q',
      eval = '<F5>',
      eval_buffer = '<F5>',
      open = 'gf',
      messages = 'M',
      save = false,
      load = false,
      resize_up = '<C-Up>',
      resize_down = '<C-Down>',
      help = 'g?'
    },
  },
}
