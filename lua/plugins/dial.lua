local mappings = require 'config.mappings'
local to_lazy, lua = mappings.to_lazy, mappings.lua
return {
  'monaqa/dial.nvim',
  events = 'VeryLazy',
  config = function()
    local augend = require 'dial.augend'
    local config = require 'dial.config'
    config.augends:register_group {
      -- default augends used when no group name is specified
      default = {
        augend.integer.alias.decimal,   -- nonnegative decimal number (0, 1, 2, 3, ...)
        augend.integer.alias.hex,       -- nonnegative hex number  (0x01, 0x1a1f, etc.)
        augend.constant.alias.bool,     -- boolean value (true <-> false)
        augend.date.alias["%Y/%m/%d"],  -- date (2022/02/19, etc.)
        augend.date.alias["%Y-%m-%d"],
        augend.date.alias["%m/%d"],
        augend.date.alias["%H:%M"],
      },
      --[[
      -- augends used when group with name `mygroup` is specified
      mygroup = {
        augend.integer.alias.decimal,
        augend.constant.alias.bool,    -- boolean value (true <-> false)
        augend.date.alias["%m/%d/%Y"], -- date (02/19/2022, etc.)
      }
      -- groups can be specified in mappings like this
      -- vim.keymap.set("n", "<Leader>a", require("dial.map").inc_normal("mygroup"), {noremap = true})
      --]]
    }

    config.augends:on_filetype {
      org = {
        -- priority
        augend.user.new {
          find = function(line, cursor)
            local s, e = line:find('%[(#[ABC])%]')
            if not s then return nil end
            if e < cursor then return nil end
            return { from = s+2, to = e-1 }
          end,
          add = function(text, addend, cursor)
            local states = { ['A'] = 3, ['B'] = 2, ['C'] = 1 }
            local next_states = { 'C', 'B', 'A' }
            local n = states[text] + addend
            -- don't wrap
            if n < 1 then
              n = 1
            elseif n > 3 then
              n = 3
            end
            local next = next_states[n]
            return { text = next }
          end,
        },
        -- checkbox
        augend.user.new {
          find = function(line)
            local s, e = line:find('%[([-x ])%]')
            if not s then return nil end
            return { from = s+1, to = e-1 }
          end,
          add = function(text, addend)
            local states = { [' '] = 3, ['-'] = 2, ['x'] = 1 }
            local next_states = { 'x', '-', ' ' }
            local n = states[text] + addend
            if n < 1 then
              n = 3
            elseif n > 3 then
              n = 1
            end
            local next = next_states[n]
            return { text = next }
          end
        },
        -- status
        augend.constant.new {
          elements = { 'TODO', 'DOING', 'WAITING', 'DELEGATED', 'DONE', 'CANCELLED' },
          cyclic = false,
        },
        -- header
        augend.user.new {
          find = function(line, cursor)
            local header_mark_s, header_mark_e = line:find "^%*+"
            if header_mark_s == nil or header_mark_e >= 7 then
              return nil
            end
            return { from = header_mark_s, to = header_mark_e }
          end,
          add = function(text, addend, cursor)
            local n = #text
            n = n + addend
            if n < 1 then
              n = 1
            end
            if n > 6 then
              n = 6
            end
            text = ("*"):rep(n)
            cursor = 1
            return { text = text, cursor = cursor }
          end,
        },
        augend.date.new {
          pattern = '%Y-%m-%d %a %H:%M',
          default_kind = 'day',
          only_valid = true,
        },
        augend.integer.alias.decimal, -- nonnegative decimal number (0, 1, 2, 3, ...)
        augend.constant.alias.bool,   -- boolean value (true <-> false)
      },
    }
  end,
  keys = to_lazy {
    -- normal
    { 'increment <cword>', '<c-a>',  lua 'require("dial.map").manipulate("increment", "normal")' },
    { 'decrement <cword>', '<c-x>',  lua 'require("dial.map").manipulate("decrement", "normal")' },
    { 'increment <cword>', 'g<c-a>', lua 'require("dial.map").manipulate("increment", "gnormal")' },
    { 'decrement <cword>', 'g<c-x>', lua 'require("dial.map").manipulate("decrement", "gnormal")' },
    -- visual
    { 'increment <cword>', '<c-a>',  lua 'require("dial.map").manipulate("increment", "visual")',  mode = 'x'  },
    { 'decrement <cword>', '<c-x>',  lua 'require("dial.map").manipulate("decrement", "visual")',  mode = 'x'  },
    { 'increment <cword>', 'g<c-a>', lua 'require("dial.map").manipulate("increment", "gvisual")', mode = 'x'  },
    { 'decrement <cword>', 'g<c-x>', lua 'require("dial.map").manipulate("decrement", "gvisual")', mode = 'x'  },
  },
}
