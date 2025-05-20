local cmd = require('mappings').cmd
return {
  "aaronik/treewalker.nvim",
  dependencies = {
    'debugloop/layers.nvim',
  },
  event = 'VeryLazy',
  -- The following options are the defaults.
  -- Treewalker aims for sane defaults, so these are each individually optional,
  -- and the whole opts block is optional as well.
  opts = {
    -- Whether to briefly highlight the node after jumping to it
    highlight = true,

    -- How long should above highlight last (in ms)
    highlight_duration = 300,

    -- The color of the above highlight. Must be a valid vim highlight group.
    -- (see :h highlight-group for options)
    highlight_group = "@string.special",

    jumplist = 'left',
  },
  config = function(_, opts)
    local tw = require('treewalker')
    tw.setup(opts)

    local TW_MODE = require('layers').mode.new()
    TW_MODE:auto_show_help()
    local toggle_key = '<c-t>'
    vim.api.nvim_set_keymap('n', toggle_key, '', {
      desc = 'TreeWalker Mode', callback = function()
        TW_MODE:activate()
      end
    })

    TW_MODE:keymaps({
      n = {
        { 'j',     cmd 'Treewalker Down',      { desc = 'Down (Next sibling)', silent = true }},
        { 'k',     cmd 'Treewalker Up',        { desc = 'Up (Prev sibling)',   silent = true }},
        { 'h',     cmd 'Treewalker Left',      { desc = 'Left (Out/Parent)',   silent = true }},
        { 'l',     cmd 'Treewalker Right',     { desc = 'Right (In/Child)',    silent = true }},
        { '<m-j>', cmd 'Treewalker SwapDown',  { desc = 'Swap Down',           silent = true }},
        { '<m-k>', cmd 'Treewalker SwapUp',    { desc = 'Swap Up',             silent = true }},
        { '<m-h>', cmd 'Treewalker SwapLeft',  { desc = 'Swap Left',           silent = true }},
        { '<m-l>', cmd 'Treewalker SwapRight', { desc = 'Swap Right',          silent = true }},
        { '<esc>', function() pcall(TW_MODE.deactivate, TW_MODE) end,
          { desc = 'Exit Treewalker Mode', silent = true } },
        { toggle_key, function() pcall(TW_MODE.deactivate, TW_MODE) end,
          { desc = 'Exit Treewalker Mode', silent = true } },
      },
    })
  end
}
