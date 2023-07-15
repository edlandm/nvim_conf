# Neovim Dotfiles

This is where I host my Neovim configuration.

I use [lazy.nvim](https://github.com/folke/lazy.nvim) to manage my plugins.

## Fennel

Most of my configuration is written in [fennel](https://fennel-lang.org/).
This is made possible with [Aniseed](https://github.com/Olical/aniseed).

All of the files inside the `fnl` directory are automatically compiled and
placed into the `lua` directory.

NOTE: There is currently one directory in the `lua` directory that I manually
manage, and that's `lua/plugins/`. These are the lazy.nvim plugin specs.
I opted to leave these in lua because a lot of plugin-configuration is copying
and pasting snippets from their documentation. It would be annoying to have to
translate everything to fennel before trying out a plugin.

## ftplugins

These are mostly still vimscript because I just copied them from my vim setup.
I'd like to eventually convert these to lua, but it's pretty low-priority (if
it ain't broke...)
