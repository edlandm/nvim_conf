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

local function run(c)    return ('<cmd>lua %s<cr>'):format(c) end
local function tab(s)    return '<tab>'..s end
local function leader(s) return '<leader>'..s end
local function pick(s)   return ('Snacks.picker.%s()'):format(s) end
local with_ivy = { layout = 'ivy_split' }

return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      win = {
        input = {
          keys = {
            ["<Esc>"]     = { "close", mode          = { "n", "i" } },
            ["<C-c>"]     = { "norm",  mode          = "i" },
            ["<C-space>"] = { "flash_open_buf", mode = "i" },
            ["_"]         = { "flash", mode          = 'n' },
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
            labels = "htsnaeicdomjlurk",
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
        flash_open_buf = function(picker)
          require("flash").jump({
            pattern = "^",
            label = { after = { 0, 0 } },
            labels = "htsnaeicdomjlurk",
            search = {
              mode = "search",
              exclude = {
                function(win)
                  return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "snacks_picker_list"
                end,
              },
            },
            action = function(match)
              picker:close()
              local idx = picker.list:row2idx(match.pos[1])
              local item = picker:items()[idx]
              vim.api.nvim_win_set_buf(0, item.buf)
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

        -- custom picker to read `.nvim.lua` and present a list of
        -- commands from the returned object (the file needs to return a table
        -- with a ['commands'] key containing a list of commands:
        -- { commands: [ { name:string, cmd:func } ] }
        ---@diagnostic disable
        Snacks.picker.holster_commands = require('holster').pickers.commands

        -- TODO: Cabinet workspace picker
        -- selecting the workspace opens it (duh)
        -- should have a keymap to edit the workspace file
      end,
    },
  },
  keys = make_mappings {
    -- picker ---------------------------------------------------------------
    { 'Pick Files',             '<c-p>',     run(pick 'files') },
    { 'Pick Directories',       tab '.',     run(pick 'directories') },
    { 'Pick Resume',            tab '<tab>', run(pick 'resume') },
    { 'Pick Buffers',           tab 'b',     run(pick 'buffers') },
    { 'SmartPicker',            tab ' ',     run(pick 'smart') },
    { 'Pick Holster',           tab 'e',     run(pick 'holster_commands') },
    { 'Pick Diagnostics <buf>', tab 'd',     function() Snacks.picker.diagnostics_buffer(with_ivy) end },
    { 'Pick Diagnostics',       tab 'D',     function() Snacks.picker.diagnostics(with_ivy) end },
    { 'Pick Commands',          tab 'C',     run(pick 'commands') },
    { 'Pick Command History',   tab ':',     run(pick 'command_history') },
    { 'Pick Search History',    tab '/',     run(pick 'search_history') },
    { 'Pick Colorschemes',      tab 'c',     run(pick 'colorschemes') },
    { 'Pick Autocmds',          tab 'A',     run(pick 'autocmds') },
    { 'Pick Help',              tab 'h',     run(pick 'help') },
    { 'Pick Registers',         tab '"',     run(pick 'registers') },
    { 'Pick Marks',             tab "'",     run(pick 'marks') },
    { 'Pick Jumps',             tab "j",     run(pick 'jumps') },
    { 'Pick Keymaps',           tab 'k',     run(pick 'keymaps') },
    { 'Pick H[i]lights',        tab 'i',     run(pick 'highlights') },
    { 'Pick Man Pages',         tab 'm',     run(pick 'man') },
    { 'Pick Undo Tree',         tab 'u',     run(pick 'undo') },
    { 'Pick Spelling',          tab 'z',     run(pick 'spelling') },
    { 'Pick Plugins',           tab 'p',     run(pick 'plugins') },
    -- git
    { 'Pick Git Branches', tab 'gb', run(pick 'git_branches') },
    { 'Pick Git Diff',     tab 'gd', run(pick 'git_diff') },
    { 'Pick Git Log',      tab 'gl', run(pick 'git_log') },
    { 'Pick Log File',     tab 'gL', run(pick 'git_log_file') },
    { 'Pick Git Files',    tab 'gf', run(pick 'git_files') },
    { 'Pick Git Status',   tab 'gs', run(pick 'git_status') },
    -- grep/search
    { 'Grep',                 '//',        run(pick 'grep') },
    { 'Grep Buffers',         leader 'sb', run(pick 'grep_buffers') },
    { 'Grep Buffer Lines ',   leader 'sl', run(pick 'lines') },
    { 'Grep <cword>',         leader 'ss', run(pick 'grep_word') },
    { 'Grep <visual>',        leader 's',  run(pick 'grep_word'), { 'x' } },
    { 'Search Quickfix List', leader 'sc', run(pick 'qflist') },
    -- LSP
    { 'Goto Definition',      'gd',   run(pick 'lsp_definitions') },
    { 'References',           'grr',  run(pick 'lsp_references') },
    { 'Goto Implementation',  'gi',   run(pick 'lsp_implementations') },
    { 'Goto Type Definition', 'gt',   run(pick 'lsp_definitions') },
    { 'LSP Symbols',          'gs',   function() Snacks.picker.lsp_symbols(with_ivy) end },
  },
}
