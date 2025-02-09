---@alias hex string a hexadecimal value (with leading '#')

---try to return the first Highlight Group found from the given name(s)
---@param ... string name(s) of highlight group(s)
---@return vim.api.keyset.get_hl_info?
local function get_hl(...)
  for _, name in ipairs({...}) do
    local hl = vim.api.nvim_get_hl(0, { name = name })
    if vim.fn.empty(hl) == 0 then
      return hl
    end
  end
end

---return an rgba integer value as a hex string (with leading '#')
---@param s integer
---@return hex
local function rgba_to_hex(s)
  return ('#%06x'):format(s)
end

---convert the background color of `hl` or return the provided default
---@param hl vim.api.keyset.get_hl_info?
---@param default hex
---@return hex
local function get_bg_or_default(hl, default)
  if hl and hl.bg then
    return rgba_to_hex(hl.bg)
  end
  return default
end

return {
  'catgoose/nvim-colorizer.lua',
  event = 'BufReadPre',
  opts = {
    filetypes = { "*", '!org' },
    user_default_options = {
      names = true, -- "Name" codes like Blue or red.  Added from `vim.api.nvim_get_color_map()`
      names_opts = { -- options for mutating/filtering names.
        lowercase = true, -- name:lower(), highlight `blue` and `red`
        camelcase = true, -- name, highlight `Blue` and `Red`
        uppercase = true, -- name:upper(), highlight `BLUE` and `RED`
        strip_digits = false, -- ignore names with digits,
        -- highlight `blue` and `red`, but not `blue3` and `red4`
      },
      -- Expects a table of color name to #RRGGBB value pairs.  # is optional
      -- Example: { cool = "#107dac", ["notcool"] = "ee9240" }
      -- Set to false|nil to disable, for example when setting filetype options
      names_custom = function()
        -- TODO: for some reason the colors from the hl groups aren't exactly
        -- what I want, even though they should be the same as these hardcoded
        -- values. Maybe they're getting updated after this code runs
        local _names = {
          note    = '#7fbbb3', -- get_bg_or_default(get_hl('DiffText'),   '#7fbbb3'),
          todo    = '#a7c080', -- get_bg_or_default(get_hl('Search'),     '#a7c080'),
          warning = '#dbbc7f', -- get_bg_or_default(get_hl('Substitute'), '#dbbc7f'),
          fixme   = '#e67e80', -- get_bg_or_default(get_hl('IncSearch'),  '#e67e80'),
        }

        -- include uppercase variants
        local names = {}
        for key, hex in pairs(_names) do
          names[key]         = hex
          names[key:upper()] = hex
        end

        return names
      end, -- Custom names to be highlighted: table|function|false|nil
      RGB      = true, -- #RGB hex codes
      RGBA     = true, -- #RGBA hex codes
      RRGGBB   = true, -- #RRGGBB hex codes
      RRGGBBAA = true, -- #RRGGBBAA hex codes
      AARRGGBB = true, -- 0xAARRGGBB hex codes
    },
    -- all the sub-options of filetypes apply to buftypes
    buftypes = {},
    -- Boolean | List of usercommands to enable
    user_commands = true, -- Enable all or some usercommands
  },
}
