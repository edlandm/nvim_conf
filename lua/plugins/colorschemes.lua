return {
  {
    'neanias/everforest-nvim',
    version = false,
    lazy = false,
    priority = 1000, -- make sure to load this before all the other start plugins
    -- Optional; default configuration will be used if setup isn't called.
    main = 'everforest',
    opts = {
      italics = true,
      ui_contrast = 'high',
      dim_inactive_windows = true,
    },
    config = true,
  },
}
