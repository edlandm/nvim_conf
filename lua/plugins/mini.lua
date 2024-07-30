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
        basics        = true,
        windows       = true,
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

    -- {{{ MiniPick
    local pick = require('mini.pick')
    pick.setup({
      options = {
        content_from_bottom = true,
      },
      window = { config = function()
        height = math.floor(0.618 * vim.o.lines)
        width = math.floor(0.618 * vim.o.columns)
        return {
          anchor = 'NW', height = height, width = width,
          row = math.floor(0.5 * (vim.o.lines - height)),
          col = math.floor(0.5 * (vim.o.columns - width)),
        }
      end }
    })

    local extra = require('mini.extra')
    extra.setup()

    local dir_explorer = function()
      extra.pickers.explorer(
        { filter = function(e) return e.fs_type == "directory" end },
        {
          mappings = {
            cd_selected_dir = {
              char = '<C-e>',
              func = function()
                local dir = pick.get_picker_matches().current
                vim.cmd.cd(dir.path)
                vim.cmd.echo('"Changed directory: '..dir.path..'"')
              end
            },
            cd_open_dir = {
              char = '<C-o>',
              func = function()
                local cwd = pick.get_picker_opts().source.cwd
                vim.cmd.cd(cwd)
                vim.cmd.echo('"Changed directory: '..cwd..'"')
              end
            }
          }
        })
    end

    vim.keymap.set('n', '<c-p>', "<cmd>Pick files<cr>", { desc = "Pick: files" })
    vim.keymap.set('n', '<tab><tab>', "<cmd>Pick resume<cr>", { desc = "Resume previous picker" })
    vim.keymap.set('n', '<tab>.', dir_explorer, { desc = "Pick: explorer" })
    vim.keymap.set('n', '<tab>/', "<cmd>Pick history scope='search'<cr>", { desc = "Pick: search history" })
    vim.keymap.set('n', '<tab>:', "<cmd>Pick history scope='cmd'<cr>", { desc = "Pick: command history" })
    vim.keymap.set('n', '<tab>b', "<cmd>Pick buffers include_current=false<cr>", { desc = "Pick: buffers" })
    vim.keymap.set('n', '<tab>c', "<cmd>Pick commands<cr>", { desc = "Pick: commands" })
    vim.keymap.set('n', '<tab>gb', "<cmd>Pick git_branches<cr>", { desc = "Pick: git branches" })
    vim.keymap.set('n', '<tab>gc', "<cmd>Pick git_commits<cr>", { desc = "Pick: git commits" })
    vim.keymap.set('n', '<tab>gh', "<cmd>Pick git_hunks<cr>", { desc = "Pick: git diff hunks" })
    vim.keymap.set('n', '<tab>gm', "<cmd>Pick git_files scope='modified'<cr>", { desc = "Pick: git modified files" })
    vim.keymap.set('n', '<tab>gu', "<cmd>Pick git_files scope='untracked'<cr>", { desc = "Pick: git untracked files" })
    vim.keymap.set('n', '<tab>h', "<cmd>Pick help<cr>", { desc = "Pick: help" })
    vim.keymap.set('n', '<tab>j', "<cmd>Pick list scope='jump'<cr>", { desc = "Pick: jumplist" })
    vim.keymap.set('n', '<tab>k', "<cmd>Pick keymaps<cr>", { desc = "Pick: keymaps" })
    vim.keymap.set('n', '<tab>l', "<cmd>Pick buf_lines scope='current'<cr>", { desc = "Pick: buffer lines (cur)" })
    vim.keymap.set('n', '<tab>L', "<cmd>Pick buf_linesscope='all'<cr>", { desc = "Pick: buffer lines (all)" })
    vim.keymap.set('n', '<tab>m', "<cmd>Pick marks<cr>", { desc = "Pick: marks" })
    vim.keymap.set('n', '<tab>p', "<cmd>Pick hipatterns<cr>", { desc = "Pick: hipatterns" })
    vim.keymap.set('n', '<tab>r', "<cmd>Pick registers<cr>", { desc = "Pick: registers" })
    vim.keymap.set('n', '<tab>q', "<cmd>Pick list scope='quickfix'<cr>", { desc = "Pick: quickfix list" })
    vim.keymap.set('n', '<tab>s', "<cmd>Pick spellsuggest<cr>", { desc = "Pick: spelling suggestions" })
    vim.keymap.set('n', '<tab>t', "<cmd>Pick treesitter<cr>", { desc = "Pick: treesitter nodes" })

    vim.keymap.set('n', 'gi', "<cmd>Pick lsp scope='implementation'<cr>", { desc = "get references to symbol under cursor" })
    vim.keymap.set('n', 'gr', "<cmd>Pick lsp scope='references'<cr>", { desc = "get references to symbol under cursor" })
    vim.keymap.set('n', 'gs', "<cmd>Pick lsp scope='document_symbol'<cr>", { desc = "list symbols current buffer" })
    vim.keymap.set('n', 'gS', "<cmd>Pick lsp scope='workspace_symbol'<cr>", { desc = "list symbols workspace" })

    vim.keymap.set('i', '<c-r><tab>', "<cmd>Pick registers<cr>")
    -- }}}
  end,
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    'lewis6991/gitsigns.nvim',
    -- 'folke/noice.nvim',
  }
}
