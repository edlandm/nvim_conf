return {
  "roobert/tabtree.nvim",
  event = "VimEnter",
  config = function()
    require("tabtree").setup({
      key_bindings = {
        next = ")",
        previous = "(",
      },
      language_configs = {
        sql = {
          target_query = [[
            (keyword_insert) @insert_capture
            (keyword_update) @update_capture
            (keyword_select) @select_capture
            (keyword_delete) @delete_capture
            (keyword_declare) @declare_capture
            (keyword_merge) @merge_capture
            (keyword_begin) @begin_capture
            (create_table) @create_table_capture
            (keyword_if) @if_capture
          ]],
          offsets = {},
        },
        c_sharp = {
          target_query = [[
          (namespace_declaration) @namespace_capture
          (class_declaration) @class_capture
          (method_declaration) @method_capture
          (constructor_declaration) @constructor_capture
          ]],
          offsets = {},
        },
        norg = {
          target_query = [[
          (heading1) @heading1_capture
          (heading2) @heading2_capture
          (heading3) @heading3_capture
          (heading4) @heading4_capture
          (heading5) @heading5_capture
          (heading6) @heading6_capture
          ]],
          offsets = {},
        },
        lua = {
          target_query = [[
          (function_definition) @function_capture
          ]],
          offsets = {},
        },
      },
    })
  end,
}
