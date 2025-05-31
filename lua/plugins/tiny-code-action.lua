local blacklist = {
  'cs', --csharp ; for some reason it freezes with this lsp
}
return {
  'rachartier/tiny-code-action.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'folke/snacks.nvim',
  },
  event = 'LspAttach',
  opts = {
    picker = 'snacks',
  },
  keys = {
    { 'gra', function()
      local m = (vim.tbl_contains(blacklist, vim.bo.filetype)
                  and vim.lsp.buf
                  or require("tiny-code-action"))
      m.code_action({})
    end, desc = 'Code Action', silent = true },
  }
}
