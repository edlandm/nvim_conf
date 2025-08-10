vim.g.mapleader = ' ' ---@diagnostic disable-line
vim.g.maplocalleader = vim.api.nvim_replace_termcodes('<BS>', false, false, true)  ---@diagnostic disable-line

require 'config.settings'.setup()
require 'config.autocmd'.setup()
require 'config.commands'
require 'config.mappings'.setup()
require 'config.lazy'
require 'quickfix'

local fs_stat = (vim.uv or vim.loop).fs_stat ---@diagnostic disable-line
local function safe_source(path)
  if not path then return end
  if type(path) == 'table' then
    for _, p in ipairs(path) do
      safe_source(type(p) == 'table' and vim.fs.joinpath(unpack(p)) or p)
    end
    return
  end
  if not fs_stat(path) then return end
  vim.cmd.source(path)
end

local config = vim.fn.stdpath('config')
local home = vim.fn.getenv('HOME')
safe_source {
  { config, 'lua', 'local.lua' },
  { config, 'lua', 'config', 'local.lua' },
  { home, '.nvim.local.lua' },
  vim.g.neovide and { config, 'lua', 'neovide_settings.lua' } or false,
}
