vim.g.mapleader = ' ' ---@diagnostic disable-line
vim.g.maplocalleader = vim.api.nvim_replace_termcodes('<BS>', false, false, true)  ---@diagnostic disable-line

require("settings").setup()
require("autocmd").setup()
require("commands")
require("mappings").setup()

local fs_stat = (vim.uv or vim.loop).fs_stat ---@diagnostic disable-line

-- Bootstrap lazy.nvim
local lazypath = vim.fs.joinpath(vim.fn.stdpath('data'), 'lazy', 'lazy.nvim')
if not fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup('plugins', {
  defaults = {
    lazy = true,
  },
  dev = {
    path = '~/s/nvim/',
    patterns = {
      '_local_',
      'edlandm',
    },
  },
  change_detection = {
    enabled = true, -- automatically check for config file changes and reload the ui
    notify = false, -- get a notification when changes are found
  },
  install = { colorschemes = { 'everforest', 'default' } },
  checker = { enabled = false },
})

local function safe_source(path)
  ---@diagnostic disable-next-line
  if fs_stat(path) then
    vim.cmd.source(path)
  end
end

local config = vim.fn.stdpath('config')
safe_source(vim.fs.joinpath(config, 'lua', 'neovide_settings.lua'))
safe_source(vim.fs.joinpath(config, 'lua', 'local.lua'))
safe_source(vim.fn.expand('~/.nvim.local.lua'))
