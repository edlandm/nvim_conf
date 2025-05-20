return {
  'jake-stewart/multicursor.nvim',
  event = 'VeryLazy',
  dependencies = {
    'debugloop/layers.nvim',
    {
      "zaucy/mcos.nvim",
      dependencies = {
        "jake-stewart/multicursor.nvim",
      },
      opts = {},
    },
  },
  config = function ()
    local mc = require 'multicursor-nvim'
    mc.setup()

    local layers = require('layers')
    local MULTI_MODE = layers.mode.new()
    MULTI_MODE:auto_show_help()

    local mc_activate = function ()
      if not MULTI_MODE:active() then
        MULTI_MODE:activate()
      end
    end

    local mappings = require('mappings')
    mappings.nmap({
      { 'Enable Multi-Cursor Mode', mappings.leader('n'), mc_activate },
      { 'Restore Multi-Cursor Mode', mappings.leader('gn'), function ()
        mc.restoreCursors()
        mc_activate()
      end },
    })

    mappings.xmap({
      { 'Enable Multi-Cursor Mode', mappings.leader('n'), function ()
        mc_activate()
        mc.matchAddCursor(1)
      end },
    })

    local mcos = require 'mcos'
    mcos.setup {}

    vim.keymap.set({ 'n', 'v' }, 'gm', function()
      mappings.operator(
        function (positions)
          mc_activate()
          vim.api.nvim_buf_set_mark(0, '<', positions.top, 0, {})
          vim.api.nvim_buf_set_mark(0, '>', positions.bottom, 0, {})
          vim.fn.feedkeys(':')
          local cmdline = ("'<,'>MCOS "):format(positions.top, positions.bottom)
          require('mcos.util').setcmdline_delayed(cmdline, #cmdline + 1)
        end)
    end)
    vim.keymap.set({ 'n' }, 'gmm', function()
      mc_activate()
      mcos.bufkeymapfunc()
    end)

    -- shorthand because I like specifying the description at the beginning
    local map = function(mapping)
      local lhs, desc, fn = unpack(mapping)
      return { lhs, fn, { desc = desc } }
    end

    MULTI_MODE:keymaps({
      n = {
        map {
          '<esc>', 'Exit Multi-Cursor Mode',
          function ()
            if mc.hasCursors() then
              mc.clearCursors()
              return
            end
            if MULTI_MODE and MULTI_MODE._active then
              -- silence errors because I have no idea why this sometimes
              -- doesn't work
              pcall(MULTI_MODE.deactivate, MULTI_MODE)
            end
          end,
        },
        map {
          'gn', 'Restore cursors',
          mc.restoreCursors,
        },
        map {
          'n', 'Add cursor and jump to next <cword>',
          function () mc.matchAddCursor(1) end,
        },
        map {
          'N', 'Add cursor and jump to prev <cword>',
          function () mc.matchAddCursor(-1) end,
        },
        map {
          's', 'Skip to next <cword>',
          function () mc.matchSkipCursor(1) end,
        },
        map {
          'S', 'Skip to prev <cword>',
          function () mc.matchSkipCursor(-1) end,
        },
        map {
          '<c-k>', 'Add cursor above the main cursor',
          function () mc.addCursor('k') end,
        },
        map {
          '<c-j>', 'Add cursor below the main cursor',
          function () mc.addCursor('j') end,
        },
        map {
          ')', 'Next cursor',
          function () mc.nextCursor() end,
        },
        map {
          '(', 'Prev cursor',
          function () mc.prevCursor() end,
        },
        map {
          '<c-t>', 'Toggle main cursor',
          function () mc.toggleCursor() end,
        },
        map {
          '<c-x>', 'Delete main cursor',
          function () mc.deleteCursor() end,
        },
        map {
          'gs', 'Split cursors by regex',
          function () mc.splitCursors() end,
        },
        map {
          '<c-l>', 'Align cursor columns',
          function () mc.alignCursors() end,
        },
        map {
          '<c-q>', 'Disable/Enable cursor movement',
          function ()
            if mc.cursorsEnabled() then
              mc.disableCursors()
            else
              mc.enableCursors()
            end
          end,
        },
        map {
          '<c-n>', 'Add cursor for all matches of <cword> in buffer',
          mc.matchAllAddCursors,
        },
        map {
          '<m-n>', 'Add cursor at next search result',
          function() mc.searchAddCursor(1) end,
        },
        map {
          '<m-s-n>', 'Add cursor at prev search result',
          function() mc.searchAddCursor(-1) end,
        },
        map {
          '<m-s>', 'Skip to next search result',
          function() mc.searchSkipCursor(1) end,
        },
        map {
          '<m-s-s>', 'Add cursor at prev search result',
          function() mc.searchSkipCursor(-1) end,
        },
      },
      x = {
        map {
          'n', 'Add cursor and jump to next word under cursor',
          function () mc.matchAddCursor(1) end,
        },
        map {
          'N', 'Add cursor and jump to previous word under cursor',
          function () mc.matchAddCursor(-1) end,
        },
      },
    })
  end
}
