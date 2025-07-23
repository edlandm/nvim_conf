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
      safe_source(p)
    end
    return
  end
  if not fs_stat(path) then return end
  vim.cmd.source(path)
end

local config = vim.fn.stdpath('config')
safe_source {
  vim.g.neovide and vim.fs.joinpath(config, 'lua', 'neovide_settings.lua') or false,
  vim.fs.joinpath(config, 'lua', 'local.lua'),
  vim.fn.expand('~/.nvim.local.lua'),
}
