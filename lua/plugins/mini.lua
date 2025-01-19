-- vim: set foldmethod=marker
return {
  'echasnovski/mini.nvim',
  version = false,
  lazy = false,
  priority = 998, -- load this after tmux-navigate
  config = function()
    -- extend/create a/i (around/in) text-objects
    require("mini.ai").setup({
        search_method = 'cover_or_prev',
    })

    -- {{{ Icons
    require("mini.icons").setup({
      style = "glyph",
    })
    -- }}}

    -- {{{ Basics - common configuration presets
    require("mini.basics").setup({
      autocommands = {
        basic = false
      },
      mappings = {
        option_toggle_prefix = [[<leader>o]],
        basics        = false,
        windows       = false,
        move_with_alt = false,
      }
    })
    -- }}}

    require("mini.bracketed").setup() -- go forward/backward with [brackets]
    vim.keymap.del('n', ']d')
    vim.keymap.del('n', ']D')
    vim.keymap.del('n', '[d')
    vim.keymap.del('n', '[D')

    require("mini.cursorword").setup() -- underline word under cursor

    -- {{{ Move - move selections of text
    require("mini.move").setup({
      mappings = {
        left  = "<",
        right = ">",
        up    = "{",
        down  = "}",
        -- I don't care about these mappings for moving the current line
        line_left  = "",
        line_right = "",
        line_up    = "",
        line_down  = "",
      }}) -- }}}

    -- statusline
    local statusline = require("mini.statusline")
    statusline.setup({
      content = {
        active = function()
          local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
          local git           = statusline.section_git({ trunc_width = 75 })
          local diagnostics   = statusline.section_diagnostics({ trunc_width = 75 })
          local filename      = statusline.section_filename({ trunc_width = 140 })
          local fileinfo      = statusline.section_fileinfo({ trunc_width = 120 })
          local location      = statusline.section_location({ trunc_width = 75 })

          return statusline.combine_groups({
            { hl = mode_hl,                  strings = { mode } },
            { hl = 'MiniStatuslineDevinfo',  strings = { git, diagnostics } },
            '%<', -- Mark general truncate point
            { hl = 'MiniStatuslineFilename', strings = { filename } },
            '%=', -- End left alignment
            { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
            { hl = mode_hl,                  strings = { location } },
          })
        end,
        inactive = nil, -- use default
      },
    })

    -- {{{ Surround - surround text-objects/motions with pairs of characters
    require("mini.surround").setup({
      mappings = {
        add            = 'ys', -- Add surrounding in Normal and Visual modes
        delete         = 'ds', -- Delete surrounding
        replace        = 'cs', -- Replace surrounding
        find           = '',   -- Find surrounding (to the right)
        find_left      = '',   -- Find surrounding (to the left)
        highlight      = '',   -- Highlight surrounding
        update_n_lines = '',   -- Update `n_lines`
        suffix_last    = '',   -- Suffix to search with "prev" method
        suffix_next    = '',   -- Suffix to search with "next" method
      },
      search_method = 'cover_or_next',
    })
    -- Remap adding surrounding to Visual mode selection
    vim.keymap.del('x', 'ys')
    vim.keymap.set('x', 'S', [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true })
    -- Make special mapping for "add surrounding for line"
    -- TODO: fix mini.surround so that it will automatically grab the line (minus
    -- leading whitespace) to surround the text in lines.
    -- having it depend on a motion does not make surrounding linewise
    -- a repeatable action without recordings
    vim.keymap.set('n', 'yss', '^ys$', { remap = true, desc = "surround current line" })
    -- }}}

    -- require("mini.tabline").setup({}) -- simple tabline

    -- {{{ Trailspace - trim trailing spaces/empty-lines from the current buffer
    local trailspace = require("mini.trailspace")
    trailspace.setup()
    vim.keymap.set('n', '<leader>ts', '<cmd>lua MiniTrailspace.trim(); MiniTrailspace.trim_last_lines()<cr>',
      { silent = true, desc = "removing trailing spaces and trailing empty lines"})
    -- }}}
  end,
  dependencies = {
    'lewis6991/gitsigns.nvim',
    -- 'folke/noice.nvim',
  }
}
