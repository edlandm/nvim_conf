return {
  "LeonHeidelbach/trailblazer.nvim",
  event = "VimEnter",
  opts = {
    force_mappings = { -- rename this to "force_mappings" to completely override default mappings and not merge with them
      nv = { -- Mode union: normal & visual mode. Can be extended by adding i, x, ...
        motions = {
          new_trail_mark         = 'mm',
          track_back             = 'm<bs>',
          peek_move_next_down    = 'mj',
          peek_move_previous_up  = 'mk',
          move_to_nearest        = 'm<space>',
          toggle_trail_mark_list = 'mq',
        },
        actions = {
          delete_all_trail_marks              = 'mc',
          paste_at_last_trail_mark            = 'mp',
          paste_at_all_trail_marks            = 'mP',
          -- set_trail_mark_select_mode          = 'ms',
          -- switch_to_next_trail_mark_stack     = 'ml',
          -- switch_to_previous_trail_mark_stack = 'mh',
          -- set_trail_mark_stack_sort_mode      = 'mS',
        },
      },
    },
  }
}
