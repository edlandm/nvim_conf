return {
  'j-hui/fidget.nvim',
  lazy = false,
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
}
