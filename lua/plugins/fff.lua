local mappings = require 'config.mappings'
local map, lua = mappings.to_lazy, mappings.lua
local pref = mappings.prefix('<leader><c-p>')
return {
  "dmtrKovalenko/fff.nvim",
  build = "cargo build --release",
  opts = {},
  keys = map {
    { 'FFF: Files',     '<c-p>',     lua 'require("fff").find_files()' },
    { 'FFF: Git Files', pref 'g',    lua 'require("fff").find_in_git_root()' },
    { 'FFF: Rescan',    pref '<F5>', lua 'require("fff").scan_files()' },
    { 'FFF: Dotfiles',  pref '.',    lua ('require("fff").find_files_in_dir("%s")'):format(vim.fn.expand('~/.config')) },
  },
}
