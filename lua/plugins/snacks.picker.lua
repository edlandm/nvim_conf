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

local edit_cmd = {
  edit    = "buffer",
  split   = "sbuffer",
  vsplit  = "vert sbuffer",
  tab     = "tab sbuffer",
  drop    = "drop",
  tabdrop = "tab drop",
}

--- this function is a copy of snacks.actions.jump, with one part removed because
--- it was making things so that if filtering the list and then changing the
--- selected item (while still in insert mode) and then confirming would always
--- cause the first item to be selected rather then the one I actually wanted
local function jump_no_reset_cursor(picker, _, action)
  local items = picker:selected({ fallback = true })

  if picker.opts.jump.close then
    picker:close()
  else
    vim.api.nvim_set_current_win(picker.main)
  end

  if #items == 0 then
    return
  end

  local win = vim.api.nvim_get_current_win()

  local current_buf = vim.api.nvim_get_current_buf()
  local current_empty = vim.bo[current_buf].buftype == ""
  and vim.bo[current_buf].filetype == ""
  and vim.api.nvim_buf_line_count(current_buf) == 1
  and vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)[1] == ""
  and vim.api.nvim_buf_get_name(current_buf) == ""

  if not current_empty then
    -- save position in jump list
    if picker.opts.jump.jumplist then
      vim.api.nvim_win_call(win, function()
        vim.cmd("normal! m'")
      end)
    end

    -- save position in tag stack
    if picker.opts.jump.tagstack then
      local from = vim.fn.getpos(".")
      from[1] = current_buf
      local tagstack = { { tagname = vim.fn.expand("<cword>"), from = from } }
      vim.fn.settagstack(vim.fn.win_getid(win), { items = tagstack }, "t")
    end
  end

  local cmd = edit_cmd[action.cmd] or "buffer"

  if cmd:find("drop") then
    local drop = {} ---@type string[]
    for _, item in ipairs(items) do
      local path = item.buf and vim.api.nvim_buf_get_name(item.buf) or Snacks.picker.util.path(item)
      if not path then
        Snacks.notify.error("Either item.buf or item.file is required", { title = "Snacks Picker" })
        return
      end
      drop[#drop + 1] = vim.fn.fnameescape(path)
    end
    vim.cmd(cmd .. " " .. table.concat(drop, " "))
  else
    for i, item in ipairs(items) do
      -- load the buffer
      local buf = item.buf ---@type number
      if not buf then
        local path = assert(Snacks.picker.util.path(item), "Either item.buf or item.file is required")
        buf = vim.fn.bufadd(path)
      end
      vim.bo[buf].buflisted = true

      -- use an existing window if possible
      if cmd == "buffer" and #items == 1 and picker.opts.jump.reuse_win and buf ~= current_buf then
        for _, w in ipairs(vim.fn.win_findbuf(buf)) do
          if vim.api.nvim_win_get_config(w).relative == "" then
            win = w
            vim.api.nvim_set_current_win(win)
            break
          end
        end
      end

      -- open the first buffer
      if i == 1 then
        vim.cmd(("%s %d"):format(cmd, buf))
        win = vim.api.nvim_get_current_win()
      end
    end
  end

  -- set the cursor
  local item = items[1]
  local pos = item.pos
  if picker.opts.jump.match then
    pos = picker.matcher:bufpos(vim.api.nvim_get_current_buf(), item) or pos
  end
  if pos and pos[1] > 0 then
    vim.api.nvim_win_set_cursor(win, { pos[1], pos[2] })
    vim.cmd("norm! zzzv")
  elseif item.search then
    vim.cmd(item.search)
    vim.cmd("noh")
  end

  -- HACK: this should fix folds
  if vim.wo.foldmethod == "expr" then
    vim.schedule(function()
      vim.opt.foldmethod = "expr"
    end)
  end

  if current_empty and vim.api.nvim_buf_is_valid(current_buf) then
    local w = vim.fn.win_findbuf(current_buf)
    if #w == 0 then
      vim.api.nvim_buf_delete(current_buf, { force = true })
    end
  end
end

local function term_picker()
  Snacks.picker.buffers({
    hidden = true,
    filter = {
      filter = function(item)
        return item.file
          :lower()
          -- TODO:lots of potential to refine this
          :match('term')
      end
    },
  })
end

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
        jump_no_reset_cursor = jump_no_reset_cursor,
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
        git_window = git_window,
      },
      confirm = 'jump_no_reset_cursor',
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
    -- favor <c-p> to use fff picker, however <tab>f is a backup if fff breaks
    { 'Pick Files',             tab 'f',     run(pick 'files') },
    { 'Pick Directories',       tab '.',     run(pick 'directories') },
    { 'Pick Resume',            tab '<tab>', run(pick 'resume') },
    { 'Pick Buffers',           tab 'b',     run(pick 'buffers') },
    { 'Pick Terminals',         tab 't',     term_picker },
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
