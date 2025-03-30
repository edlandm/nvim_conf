return {
  'hat0uma/csvview.nvim',
  ft = { 'csv', 'tsv' },
  opts = {
    parser = { comments = { "#", "//" } },
    header_lnum = 1,
    view = {
      min_column_width = 3,
      display_mode = 'border',
      sticky_header = { enabled = true }
    },
    keymaps = {
      -- Text objects for selecting fields
      textobject_field_inner = { "if", mode = { "o", "x" } },
      textobject_field_outer = { "af", mode = { "o", "x" } },
      -- Excel-like navigation:
      -- Use <Tab> and <S-Tab> to move horizontally between fields.
      -- Use <Enter> and <S-Enter> to move vertically between rows and place the cursor at the end of the field.
      -- Note: In terminals, you may need to enable CSI-u mode to use <S-Tab> and <S-Enter>.
      jump_next_field_end = { "<Right>", mode = { "n", "v" } },
      jump_prev_field_end = { "<Left>", mode = { "n", "v" } },
      jump_next_row = { "<Down>", mode = { "n", "v" } },
      jump_prev_row = { "<Up>", mode = { "n", "v" } },
    },
  },
  event = 'VeryLazy',
  cmd = { 'CsvViewEnable', 'CsvViewDisable', 'CsvViewToggle' },
  keys = {
    -- {  },
  },
}
