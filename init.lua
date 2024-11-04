require("settings")
require("autocmd")
require("mappings")

-- install lazy.nvim (plugin manager) if needed
local lazypath = vim.fn.stdpath('config') .. '/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  defaults = { lazy = true },
  dev = {
    path = '~/s/nvim/',
    patterns = {
      '_local_',
    },
  }
})

---- Local Plugins And Config
require('plugin-projects')

local function safe_source(path)
  if vim.loop.fs_stat(path) then
    vim.cmd.source(path)
  end
end

safe_source(vim.fn.stdpath('config') .. '/lua/neovide_settings.lua')
safe_source(vim.fn.stdpath('config') .. '/lua/local.lua')
safe_source(vim.fn.expand('~/.nvim.local.lua'))
