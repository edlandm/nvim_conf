return {
  'edlandm/freeze.nvim', -- I wrote this one :)
  event = 'VeryLazy',
  opts = {
    -- style gallery: https://xyproto.github.io/splash/docs/index.html
    theme_light   = 'catppuccin-latte',
    theme_dark    = 'catppuccin-frappe',
    default_theme = 'dark',
    filename      = '{timestamp}-{filename}-{start_line}-{end_line}.png',
  },
  config = function (context)
    local freeze = require('freeze')
    freeze.setup(context)

    local mappings = require('mappings')
    local pref = mappings.leader('f')

    mappings.nmap({
      { 'Freeze: take screenshot of <operator> range', pref,      freeze.freeze_operator  },
      { 'Freeze: take screenshot of current buffer',   pref..'f', freeze.freeze },
      { 'Freeze: toggle light/dark/theme',             pref..'t', freeze.toggle_theme },
    })

    mappings.xmap({
      { 'Freeze: take screenshot of selected range', pref, freeze.freeze_visual },
    })
  end,
}
