---shorthand for creating keymaps in a format that I prefer
---@param maps [string,string,string|function][]
local function make_mappings(maps)
  local mappings = {}
  for _, map in ipairs(maps) do
    local desc, lhs, rhs, mode = unpack(map)
    table.insert(mappings, { lhs, rhs, desc = desc, mode = mode or 'n' })
  end
  return mappings
end

local function pref(s) return ('<leader>t%s'):format(s) end
local function run(c) return ('<cmd>lua %s<cr>'):format(c) end
local br = function(args, opts)
  local nosplit = false
  local _opts = opts or {}
  if opts == false then
    nosplit = true
  end

  local cmd = string.format(
    'source %s/.config/broot/launcher/bash/br;br %s',
    vim.fn.getenv('HOME'),
    args or '')

  if nosplit then
    vim.cmd.term(cmd)
  else
    Snacks.terminal(cmd, _opts)
  end
end

local float      = { win = { style = 'float' } }
local horizontal = { win = { style = 'split' } }
local vertical   = { win = { style = 'split', position = 'right' } }
local home = vim.fn.getenv('HOME')

return {
  'folke/snacks.nvim',
  terminal = { enabled = false },
  --[[
  keys = make_mappings({
    -- terminal mappings
    -- want to have ones for opening in current window, float, horizontal, and vertical
    -- want ones for opening to just shell, and also for opening broot (br)
    { 'Term',                    pref 't', '<cmd>term<cr>' },
    { 'Term: Matrix',            pref 'm', '<cmd>term fakesteak<cr>' },
    { 'Term: toggle float',      pref 'f', function() Snacks.terminal.toggle(nil, float) end },
    { 'Term: toggle split',      pref 's', function() Snacks.terminal.toggle(nil, horizontal) end },
    { 'Term: toggle vert',       pref 'v', function() Snacks.terminal.toggle(nil, vertical) end },
    { 'Term: broot',             pref 'be', function() br(nil, false)      end },
    { 'Term: broot split',       pref 'bs', function() br(nil, horizontal) end },
    { 'Term: broot vert',        pref 'bv', function() br(nil, vertical)   end },
    { 'Term: broot $HOME',       pref 'Be', function() br(home, false)      end },
    { 'Term: broot $HOME split', pref 'Bs', function() br(home, horizontal) end },
    { 'Term: broot $HOME vert',  pref 'Bv', function() br(home, vertical)   end },
  }),
  --]]
}
