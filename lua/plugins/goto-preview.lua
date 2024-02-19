return {
  'rmagatti/goto-preview',
  opts = {},
  keys = {
    {'gd', "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", 'n', desc = "goto definition"},
    {'gt', "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>", 'n', desc = "goto type definition"},
  },
}
