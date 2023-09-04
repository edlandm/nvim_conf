if !has("nvim")
  echo "This file is only compatible with neovim"
  finish
endif

lua << EOF
  -- install lazy.nvim (plugin manager) if needed
  local lazypath = vim.fn.stdpath("config") .. "/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable", -- latest stable release
      lazypath,
    })
  end
  vim.opt.rtp:prepend(lazypath)

  vim.g.mapleader = " "
  vim.g.maplocalleader = ","

  -- load plugins

  require("lazy").setup("plugins", {
    defaults = { lazy = true },
    dev = {
        path = "~/s/nvim/",
        patterns = {
          "_local_",
        },
      }
    })

  -- automatically compile and load Fennel code as if it were natively
  -- supported by the editor
  vim.g["aniseed#env"] = true
  require("aniseed.env").init()
EOF
