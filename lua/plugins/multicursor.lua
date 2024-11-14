return {
  'jake-stewart/multicursor.nvim',
  event = 'VeryLazy',
  dependencies = {
    'debugloop/layers.nvim'
  },
  config = function ()
    local mc = require('multicursor-nvim')
    mc.setup()

    local layers = require('layers')
    local MULTI_MODE = layers.mode.new()
    MULTI_MODE:auto_show_help()

    -- MULTI_MODE:add_hook(function ()
    --   vim.cmd('redrawstatus')
    -- end)

    local mappings = require('mappings')
    mappings.nmap({
      { 'Enable Multi-Cursor Mode', mappings.leader('n'),
        function () MULTI_MODE:activate() end },
      { 'Restore Multi-Cursor Mode', mappings.leader('gn'), function ()
        mc.restoreCursors()
        if not MULTI_MODE:active() then
          MULTI_MODE:activate()
        end
      end },
    })

    mappings.xmap({
      { 'Enable Multi-Cursor Mode', mappings.leader('n'), function ()
        MULTI_MODE:activate()
        mc.matchAddCursor(1)
      end },
    })

    MULTI_MODE:keymaps({
      n = {
        {
          '<esc>',
          function ()
            if mc.hasCursors() then
              mc.clearCursors()
              return
            end
            if MULTI_MODE then
              MULTI_MODE:deactivate()
            end
          end,
          { desc = 'Exit Multi-Cursor Mode' }
        },
        {
          'n',
          function () mc.matchAddCursor(1) end,
          { desc = 'Add cursor and jump to next <cword>' }
        },
        {
          'N',
          function () mc.matchAddCursor(-1) end,
          { desc = 'Add cursor and jump to prev <cword>' }
        },
        {
          's',
          function () mc.matchSkipCursor(1) end,
          { desc = 'Skip to next <cword>' }
        },
        {
          'S',
          function () mc.matchSkipCursor(-1) end,
          { desc = 'Skip to prev <cword>' }
        },
        {
          '<c-k>',
          function () mc.addCursor('k') end,
          { desc = 'Add cursor above the main cursor' }
        },
        {
          '<c-j>',
          function () mc.addCursor('j') end,
          { desc = 'Add cursor below the main cursor' }
        },
        {
          '<c-n>',
          function () mc.nextCursor() end,
          { desc = 'Next cursor' }
        },
        {
          '<c-p>',
          function () mc.prevCursor() end,
          { desc = 'Prev cursor' }
        },
        {
          '<c-t>',
          function () mc.toggleCursor() end,
          { desc = 'Toggle main cursor' }
        },
        {
          '<c-x>',
          function () mc.deleteCursor() end,
          { desc = 'Delete main cursor' }
        },
        {
          '<c-s>',
          function () mc.splitCursors() end,
          { desc = 'Split cursors by regex' }
        },
        {
          '<c-l>',
          function () mc.alignCursors() end,
          { desc = 'Align cursor columns' }
        },
        {
          '<c-q>',
          function ()
            if mc.cursorsEnabled() then
              mc.disableCursors()
            else
              mc.enableCursors()
            end
          end,
          { desc = 'Disable/Enable cursor movement' },
        }
      },
      x = {
        {
          'n',
          function () mc.matchAddCursor(1) end,
          { desc = 'Add cursor and jump to next word under cursor' }
        },
        {
          'N',
          function () mc.matchAddCursor(-1) end,
          { desc = 'Add cursor and jump to previous word under cursor' }
        },
      },
    })
  end
}
