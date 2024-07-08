return {
  "max397574/better-escape.nvim",
  event = "VimEnter",
  config = function ()
    require("better_escape").setup({
      timeout = vim.o.timeoutlen,
      mappings = {
        i = {
          h = {
            h = "<esc>",
            s = "<esc>",
          },
        },
      },
    })
  end,
}
