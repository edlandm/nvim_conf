vim.g.mapleader = " "
vim.g.maplocalleader = vim.api.nvim_replace_termcodes('<BS>', false, false, true)

require("settings").setup()
require("autocmd").setup()
require("commands")
require("mappings").setup()

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
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
  checker = { enabled = true },
})

-- Local Plugins And Config
require('plugin-projects')

local function safe_source(path)
  if vim.loop.fs_stat(path) then
    vim.cmd.source(path)
  end
end

safe_source(vim.fn.stdpath('config') .. '/lua/neovide_settings.lua')
safe_source(vim.fn.stdpath('config') .. '/lua/local.lua')
safe_source(vim.fn.expand('~/.nvim.local.lua'))
