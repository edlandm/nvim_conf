-- Flatten allows you to open files from a neovim terminal buffer in your
-- current neovim instance instead of a nested one.
return {
  "willothy/flatten.nvim",
  lazy = false,
  opts = {
    block_for = {
      gitcommit = true,
      gitrebase = true,
    },
    window = {
      open = "current",
      focus = "first",
    },
  }
}
