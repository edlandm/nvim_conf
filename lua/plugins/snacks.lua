---shorthand for creating keymaps in a format that I prefer
---@param maps [string,string,string|function][]
local function make_mappings(maps)
  local mappings = {}
  for _, map in ipairs(maps) do
    local desc, lhs, rhs, mode = unpack(map)
    table.insert(mappings, { lhs, rhs, desc = desc, mode = mode or 'n' })
  end
  return mappings
end

local function run(c) return ('<cmd>lua %s<cr>'):format(c) end
local function tab(s) return '<tab>'..s end
local function leader(s) return '<leader>'..s end
local function pick(s) return ('Snacks.picker.%s()'):format(s) end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    zen = { enabled = true },
    dim = { enabled = true },
    debug = { enabled = true },
    scroll = { enabled = true },
    win = { enabled = true },
    indent = {
      enabled = true,
      -- |¦‖｜￤∥ǀ∣│❘┃
      char = '┃',
      hl = {
        "SnacksIndent1",
        "SnacksIndent2",
        "SnacksIndent3",
        "SnacksIndent4",
        "SnacksIndent5",
        "SnacksIndent6",
        "SnacksIndent7",
        "SnacksIndent8",
      },
      only_scope = false, -- only show indent guides of the scope
      scope = {
        enabled = true, -- enable highlighting the current scope
        priority = 200,
        char = "┃",
        underline = false, -- underline the start of the scope
        only_current = false, -- only show scope in the current window
        hl = {
          "SnacksIndent1",
          "SnacksIndent2",
          "SnacksIndent3",
          "SnacksIndent4",
          "SnacksIndent5",
          "SnacksIndent6",
          "SnacksIndent7",
          "SnacksIndent8",
        },
      },
      animate = {
        enabled = vim.fn.has("nvim-0.10") == 1,
        style = "out",
        easing = "linear",
        duration = {
          step = 40, -- ms per step
          total = 300, -- maximum duration
        },
      },
    },
    picker = {
      win = {
        input = {
          keys = {
            ["<Esc>"] = { "close", mode = { "n", "i" } },
            ["<C-c>"] = { "norm", mode = "i" },
            ["<C-_>"] = { "flash", mode = { "n", "i" } },
            ["_"]     = { "flash" },
          },
        },
        preview = {
          wo = {
            foldenable = false,
          },
        },
      },
      actions = {
        flash = function(picker)
          require("flash").jump({
            pattern = "^",
            label = { after = { 0, 0 } },
            search = {
              mode = "search",
              exclude = {
                function(win)
                  return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "snacks_picker_list"
                end,
              },
            },
            action = function(match)
              local idx = picker.list:row2idx(match.pos[1])
              picker.list:_move(idx, true, true)
            end,
          })
        end,
      },
      config = function(_)
        local custom_pickers = require('pickers')

        -- custom picker to list only directories
        -- cd to selected dir with <c-e>
        -- <cr> opens the directory in oil
        -- TODO: currently an empty buffer is opened and you need to re-edit
        -- it with `:e` to get oil to open up; not sure why
        ---@diagnostic disable
        Snacks.picker.directories = custom_pickers.directories

        -- custom picker to list Lazy plugins
        -- <c-r> reloads the plugin
        ---@diagnostic disable
        Snacks.picker.plugins = custom_pickers.plugins

        -- TODO: Cabinet workspace picker
        -- selecting the workspace opens it (duh)
        -- should have a keymap to edit the workspace file
      end,
    },
  },
  keys = make_mappings({
    { 'Zen Mode', '<leader>z', run 'Snacks.zen()' },
    { 'Zoom',     '<leader>Z', run 'Snacks.zen.zoom()' },
    -- picker ---------------------------------------------------------------
    { 'Pick Files',             '<c-p>',      run(pick 'files') },
    { 'Pick Directories',       tab('.'),     run(pick 'directories') },
    { 'Pick Resume',            tab('<tab>'), run(pick 'resume') },
    { 'SmartPicker',            tab(' '),     run(pick 'smart') },
    { 'Pick Diagnostics <buf>', tab('d'),     run(pick 'diagnostics_buffer') },
    { 'Pick Diagnostics',       tab('D'),     run(pick 'diagnostics') },
    { 'Pick Commands',          tab('C'),     run(pick 'commands') },
    { 'Pick Command History',   tab(':'),     run(pick 'command_history') },
    { 'Pick Search History',    tab('/'),     run(pick 'search_history') },
    { 'Pick Colorschemes',      tab('c'),     run(pick 'colorschemes') },
    { 'Pick Autocmds',          tab('A'),     run(pick 'autocmds') },
    { 'Pick Help',              tab('h'),     run(pick 'help') },
    { 'Pick Registers',         tab('"'),     run(pick 'registers') },
    { 'Pick Marks',             tab("'"),     run(pick 'marks') },
    { 'Pick Jumps',             tab("j"),     run(pick 'jumps') },
    { 'Pick Keymaps',           tab('k'),     run(pick 'keymaps') },
    { 'Pick H[i]lights',        tab('i'),     run(pick 'highlights') },
    { 'Pick Man Pages',         tab('m'),     run(pick 'man') },
    { 'Pick Undo Tree',         tab('u'),     run(pick 'undo') },
    { 'Pick Spelling',          tab('z'),     run(pick 'spelling') },
    { 'Pick Plugins',           tab('p'),     run(pick 'plugins') },
    -- git
    { 'Pick Git Branches',      tab('gb'),    run(pick 'git_branches') },
    { 'Pick Git Diff',          tab('gd'),    run(pick 'git_diff') },
    { 'Pick Git Log',           tab('gl'),    run(pick 'git_log') },
    { 'Pick Log File',          tab('gL'),    run(pick 'git_log_file') },
    { 'Pick Git Files',         tab('gf'),    run(pick 'git_files') },
    { 'Pick Git Status',        tab('gs'),    run(pick 'git_status') },
    -- grep/search
    { 'Grep',                   '//',         run(pick 'grep') },
    { 'Grep Buffers',           leader('sb'), run(pick 'grep_buffers') },
    { 'Grep Buffer Lines ',     leader('sl'), run(pick 'lines') },
    { 'Grep <cword>',           leader('ss'), run(pick 'grep_word') },
    { 'Grep <visual>',          leader('s'),  run(pick 'grep_word'),             { 'x' } },
    { 'Search Quickfix List',   leader('sc'), run(pick 'qflist') },
    -- LSP
    { 'Goto Definition',        'gd',         run(pick 'lsp_definitions') },
    { 'References',             'grr',        run(pick 'lsp_references') },
    { 'Goto Implementation',    'gi',         run(pick 'lsp_implementations') },
    { 'Goto Type Definition',   'gt',         run(pick 'lsp_definitions') },
    { 'LSP Symbols',            'gs',         run(pick 'lsp_symbols') },
  }),
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        _G.Snacks = require('snacks')
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command
      end,
    })

    vim.api.nvim_create_user_command('News', function()
      local file
      for _, f in ipairs(vim.api.nvim_get_runtime_file("doc/news.txt", true)) do
        -- I happen to have multiple matches for doc/news.txt in my runtime
        -- files, so I need to find the actual neovim one
        -- (others are for plugins)
        if f:match('nvim/runtime/doc/news.txt') then
          file = f
          break
        end
      end

      if not file then
        print('News file not found')
        return
      end

      Snacks.win({
        file = file,
        width = 0.6,
        height = 0.7,
        wo = {
          spell = false,
          wrap = false,
          signcolumn = "yes",
          statuscolumn = " ",
          conceallevel = 3,
        },
      })

    end, { desc = 'Open Neovim News in floating window' })
  end,
}
