return {
  "rachartier/tiny-inline-diagnostic.nvim",
  event = "VeryLazy",
  config = function ()
    require("tiny-inline-diagnostic").setup()

    local groupid = vim.api.nvim_create_augroup("tiny-inline-diagnostic", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "BufNewFile" },
      { pattern = "*", group = groupid,
      callback = function ()
        vim.diagnostic.config({ virtual_text = false })
      end })
  end,
}
