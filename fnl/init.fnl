(module init
  {autoload {a aniseed.core
            nvim aniseed.nvim
            u util}})

(require "core")
(require "mappings")

;; source machine-local config file
(vim.cmd "silent! source ~/.nvim.local.lua")
