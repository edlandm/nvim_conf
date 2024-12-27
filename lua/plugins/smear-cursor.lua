-- Smooth cursor movement.
return {
  "sphamba/smear-cursor.nvim",
  -- enabled = false,
  event = 'VimEnter',
  opts  = {
    -- -- Smear cursor when switching buffers
    -- smear_between_buffers = false,

    -- -- Smear cursor when moving within line or to neighbor lines
    smear_between_neighbor_lines = false,

    -- -- Use floating windows to display smears over wrapped lines or outside buffers.
    -- -- May have performance issues with other plugins.
    use_floating_windows = false,

    -- Set to `true` if your font supports legacy computing symbols (block unicode symbols).
    -- Smears will blend better on all backgrounds.
    legacy_computing_symbols_support = false,

                                   -- default  valid values/ranges
    stiffness = 0.8,               -- 0.6      [0, 1]
    trailing_stiffness = 0.5,      -- 0.3      [0, 1]
    distance_stop_animating = 0.5, -- 0.1      > 0
    hide_target_hack = true,       -- true     boolean
  },
}
