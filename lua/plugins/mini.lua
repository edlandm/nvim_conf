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

    -- {{{ Animate - animations when scrolling, moving cursor, resizing windows
    local animate = require("mini.animate")
    animate.setup({
      cursor = { timing = animate.gen_timing.exponential({ duration = 3 }) },
      scroll = { timing = animate.gen_timing.quartic({ duration = 3 }) },
      resize = { timing = animate.gen_timing.exponential({ duration = 3 }) },
      open   = { timing = animate.gen_timing.quadratic({ duration = 10 }) },
      close  = { timing = animate.gen_timing.quadratic({ duration = 10 }) },
    }) -- }}}

    -- {{{ Basics - common configuration presets
    require("mini.basics").setup({
      mappings = {
        option_toggle_prefix = [[<leader>o]],
        basics        = true,
        windows       = true,
        move_with_alt = false,
      }
    })
    -- delete the keymaps I don't like
    vim.keymap.del({'n', 'i', 'v'}, '<c-s>')
    -- }}}

    require("mini.bracketed").setup() -- go forward/backward with [brackets]
    vim.keymap.del('n', ']d')
    vim.keymap.del('n', ']D')
    vim.keymap.del('n', '[d')
    vim.keymap.del('n', '[D')

    -- {{{ Comments - toggle comments on objects+motions
    require("mini.comment").setup({
      options = {
        ignore_blank_line = true,
        custom_commentstring = function(pos)
          if vim.bo.commentstring then
            return vim.bo.commentstring
          end
        end
      },
      mappings = {
        comment      = '<leader>c',
        comment_line = '<leader>cc',
        textobject   = '<leader>c',
      }
    })
    vim.keymap.set('n', '<leader>cy', 'yy<leader>cc',
      { remap = true, silent = true, desc = "yank line and comment it" })
    vim.keymap.set('i', ';c', '<cmd>lua MiniComment.toggle_lines(vim.fn.line("."), vim.fn.line("."))<cr>',
    { desc = "comment current line" })
    -- }}}

    require("mini.cursorword").setup() -- underline word under cursor

    -- {{{ HiPatterns - highlight patterns in text
    -- also highlight hex color strings using that color
    local hipatterns = require('mini.hipatterns')
    hipatterns.setup({
      highlighters = {
        -- Highlight standalone 'FIXME', 'WARNING', 'TODO', 'NOTE'
        fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
        hack  = { pattern = '%f[%w]()WARNING()%f[%W]',  group = 'MiniHipatternsWarning'  },
        todo  = { pattern = '%f[%w]()TODO()%f[%W]',  group = 'MiniHipatternsTodo'  },
        note  = { pattern = '%f[%w]()NOTE()%f[%W]',  group = 'MiniHipatternsNote'  },
        -- Highlight hex color strings (`#rrggbb`) using that color
        hex_color = hipatterns.gen_highlighter.hex_color(),
      },
    }) -- }}}

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

    require("mini.splitjoin").setup() -- split/join args/items with `gS`

    -- statusline
    require("mini.statusline").setup({
      content = {
        active = function()
          local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
          local git           = MiniStatusline.section_git({ trunc_width = 75 })
          local diagnostics   = MiniStatusline.section_diagnostics({ trunc_width = 75 })
          local filename      = MiniStatusline.section_filename({ trunc_width = 140 })
          local fileinfo      = MiniStatusline.section_fileinfo({ trunc_width = 120 })
          local location      = MiniStatusline.section_location({ trunc_width = 75 })

          return MiniStatusline.combine_groups({
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

    -- {{{ MiniPick
    local pick = require('mini.pick')
    pick.setup({
      options = {
        content_from_bottom = true,
      },
    })
    require('mini.extra').setup()

    vim.keymap.set('n', '<c-p>', "<cmd>Pick files<cr>")
    vim.keymap.set('n', '<leader><tab>', "<cmd>Pick resume<cr>")

    vim.keymap.set('n', '<tab>.', function()
      MiniExtra.pickers.explorer(
        { filter = function(e) return e.fs_type == "directory" end },
        {
          mappings = {
            cd_selected_dir = {
              char = '<C-e>',
              func = function()
                local dir = MiniPick.get_picker_matches().current
                vim.cmd.cd(dir.path)
                vim.cmd.echo('"Changed directory: '..dir.path..'"')
              end
            },
            cd_open_dir = {
              char = '<C-o>',
              func = function()
                local cwd = MiniPick.get_picker_opts().source.cwd
                vim.cmd.cd(cwd)
                vim.cmd.echo('"Changed directory: '..cwd..'"')
              end
            }
          }
        })
    end)

    vim.keymap.set('n', '<tab>/', "<cmd>Pick history scope='search'<cr>")
    vim.keymap.set('n', '<tab>:', "<cmd>Pick history scope='cmd'<cr>")
    vim.keymap.set('n', '<tab>b', "<cmd>Pick buffers<cr>")
    vim.keymap.set('n', '<tab>c', "<cmd>Pick commands<cr>")
    vim.keymap.set('n', '<tab>d', "<cmd>Pick diagnostic<cr>")
    vim.keymap.set('n', '<tab>gb', "<cmd>Pick git_branches<cr>")
    vim.keymap.set('n', '<tab>gc', "<cmd>Pick git_commits<cr>")
    vim.keymap.set('n', '<tab>gh', "<cmd>Pick git_hunks<cr>")
    vim.keymap.set('n', '<tab>gm', "<cmd>Pick git_files scope='modified'<cr>")
    vim.keymap.set('n', '<tab>gu', "<cmd>Pick git_files scope='untracked'<cr>")
    vim.keymap.set('n', '<tab>h', "<cmd>Pick help<cr>")
    vim.keymap.set('n', '<tab>k', "<cmd>Pick keymaps<cr>")
    vim.keymap.set('n', '<tab>l', "<cmd>Pick buf_lines<cr>")
    vim.keymap.set('n', '<tab>m', "<cmd>Pick marks<cr>")
    vim.keymap.set('n', '<tab>p', "<cmd>Pick hipatterns<cr>")
    vim.keymap.set('n', '<tab>r', "<cmd>Pick registers<cr>")
    vim.keymap.set('n', '<tab>q', "<cmd>Pick list scope='quickfix'<cr>")
    vim.keymap.set('n', '<tab>s', "<cmd>Pick spellsuggest<cr>")
    vim.keymap.set('n', '<tab>t', "<cmd>Pick treesitter<cr>")

    vim.keymap.set('i', '<c-r><tab>', "<cmd>Pick registers<cr>")
    -- }}}
  end,
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    'lewis6991/gitsigns.nvim',
    -- 'folke/noice.nvim',
  }
}
