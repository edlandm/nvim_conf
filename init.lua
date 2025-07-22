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
  ---@diagnostic disable-next-line
  if fs_stat(path) then
    vim.cmd.source(path)
  end
end

local config = vim.fn.stdpath('config')
if vim.g.neovide then
  safe_source(vim.fs.joinpath(config, 'lua', 'neovide_settings.lua'))
end
safe_source(vim.fs.joinpath(config, 'lua', 'local.lua'))
safe_source(vim.fn.expand('~/.nvim.local.lua'))
