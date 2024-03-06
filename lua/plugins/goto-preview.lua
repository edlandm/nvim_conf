return {
  'rmagatti/goto-preview',
  opts = {},
  keys = {
    {'g=', "<cmd>lua require('goto-preview').goto_preview_declaration()<CR>", 'n', desc = "goto declaration"},
    {'gd', "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", 'n', desc = "goto definition"},
    {'gt', "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>", 'n', desc = "goto type definition"},
  },
}
