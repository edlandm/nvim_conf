local function pref(s)   return '<leader>f' .. (s or '') end
local function cmd(s)    return ('<cmd>%s<cr>'):format(s) end
local function freeze(s) return ('lua require("freeze"):%s()'):format(s) end
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
  keys = {
    { pref(),   cmd(freeze 'freeze_operator'), desc = 'Freeze: take screenshot of <operator> range'  },
    { pref 'f', cmd(freeze 'freeze'),          desc = 'Freeze: take screenshot of current buffer' },
    { pref 't', cmd(freeze 'toggle_theme'),    desc = 'Freeze: toggle light/dark/theme' },
    { pref(),   cmd(freeze 'freeze_visual'),   desc = 'Freeze: take screenshot of selected range', mode = 'x' },
  },
}
