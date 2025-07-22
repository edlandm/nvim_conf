local mappings = require 'config.mappings'
local leader, cmd, prefix, map = mappings.leader, mappings.cmd, mappings.prefix, mappings.to_lazy
local pref = prefix(leader 'NF')
return {
  'j-hui/fidget.nvim',
  lazy = false,
  init = function()
    require 'which-key'.add { pref(), group = 'Fidget Notifications' }
  end,
  opts = {
    -- Options related to notification subsystem
    notification = {
      filter = vim.log.levels.INFO, -- Minimum notifications level
      override_vim_notify = true,  -- Automatically override vim.notify() with Fidget
      poll_rate = 10,               -- How frequently to update and render notifications
      history_size = 128,           -- Number of removed messages to retain in history
      -- redirect =                    -- Conditionally redirect notifications to another backend
        -- function(msg, level, opts)
        --   if opts and opts.on_open then
        --     return require("fidget.integration.nvim-notify").delegate(msg, level, opts)
        --   end
        -- end,
    },
  },
  keys = map {
    { 'Fidget: Show History',  pref 'h', cmd 'Fidget history' },
    { 'Fidget: Clear History', pref 'c', cmd 'Fidget clear_history' },
  }
}
