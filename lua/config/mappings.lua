local api = vim.api
local fun = vim.fn
local util = require('util')
local prompt, nilif = util.prompt, util.nilif

local function prefix(p)
  assert(p, 'argument required')
  return function(s) return p .. (s or '') end
end

---return a function that takes a string and wraps it with `s` [and `e`]
---@param b string begin
---@param e string end
---@return fun(s:string):string
local function wrap(b, e)
  assert(b, 'argument required')
  return function(s) return ('%s%s%s'):format(b, s, e or b) end
end

local leader = prefix '<leader>'
local lleader = prefix '<localleader>'
local cmd = wrap('<cmd>', '<cr>')
local lua = wrap('<cmd>lua ', '<cr>')

-- MODULE STUFF ==============================================================
local M = {}

--- @alias abbrev_mode 'ia' | 'ca' | '!a'
--- @alias vim_mode 'n' | 'i' | 'x' | 't' | 'c' | 'l' | 'v' | 's' | 'o' | abbrev_mode
--- @alias desc string
--- @alias lhs string
--- @alias rhs string | function
---@alias keymap [ desc, lhs, rhs, table? ]
---@alias keymap_group { mode?:string, buf?:boolean, buffer?:boolean, noremap?:boolean, noremap?:boolean, silent?:boolean, expr?:boolean, [integer]:keymap }

--- @alias jumpDest 'start' | 'end' | 'top' | 'bottom' | 'origin'
--- @alias operatorOpts { jump:jumpDest? }
--- @alias operatorPositions { top:integer, bottom:integer, start:integer, end:integer }
--- @alias visualOpts { jump:'top'|'bottom'|'origin'?, resume_visual:boolean? }
--- @alias position [integer, integer]
--- @alias selectionType 'char' | 'line' | 'block
--- @alias visualRange { top:position, bottom:position, selection_type:selectionType }

---shortcut fn to make mappings in my prefered format (description first)
---@param keymap_groups keymap_group | keymap_group[]
function M.map(keymap_groups)
  local function setmap(mode, buf, defaults, keymap)
      -- vim.print({ mode=mode, buf=buf, defaults=defaults, keymap=keymap })
      local desc, lhs, rhs, _opts = unpack(keymap)
      local opts = vim.tbl_deep_extend('keep',
        _opts or {},
        { desc = desc, callback = type(rhs) == 'function' and rhs or nil },
        defaults)

      if type(rhs) == 'function' then
        rhs = ''
      end

      if nilif(desc, '') and nilif(lhs, '') then
        if buf then
          vim.api.nvim_buf_set_keymap(0, mode, lhs, rhs, opts)
        else
          vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
        end
      end
  end

  local function set_group_maps(group)
    local mode     = group.mode or 'n'
    local buf      = group.buf or group.buffer or false
    local defaults = {
      noremap = group.noremap == false and false or true,
      silent  = group.silent  == false and false or true,
      expr    = group.expr and true or false,
    }

    -- vim.print { mode=mode, buf=buf, defaults=defaults }
    for _, keymap in ipairs(group) do
      setmap(mode, buf, defaults, keymap)
    end
  end

  local is_list_of_list_of_mappings = (type(keymap_groups) == 'table'
    and type(keymap_groups[1]) == 'table'
    and type(keymap_groups[1][1]) == 'table')

  local is_list_of_of_mappings = (type(keymap_groups) == 'table'
    and type(keymap_groups[1]) == 'table'
    and type(keymap_groups[1][1]) == 'string')

  if is_list_of_list_of_mappings then
    for _, group in ipairs(keymap_groups) do
      set_group_maps(group)
    end
  elseif is_list_of_of_mappings then
      set_group_maps(keymap_groups)
  else
    vim.notify('map :: unexpected keymap_group format', vim.log.levels.ERROR, {})
  end
end

---@alias to_lazy_keymap { [1]:string, [2]:string, [3]:string|function, [string]:string }
---@alias LazyKeySpec table

---convenience function that takes a list of mapping tuples in the format that
---I prefer (description-first for readability) and returns a LazyKeySpec[]
---@param keymap to_lazy_keymap|{ [integer]: to_lazy_keymap, [string]:any }
---@return LazyKeySpec|LazyKeySpec[]
function M.to_lazy(keymap)
  do -- type assertions
    local _type = type(keymap)
    assert(_type == 'table',
      ('expected either a tuple or list of tuples. Got: <%s>')
        :format(_type))
  end
  if type(keymap[1]) == 'table' then -- list of keymaps
    local properties = {}
    local keymaps = {}
    for key, value in pairs(keymap) do
      if type(key) == 'string' then
        properties[key] = value
      else
        table.insert(keymaps, value)
      end
    end
    return vim.tbl_map(function (km)
      return M.to_lazy(vim.tbl_deep_extend('keep', km, properties))
    end, keymaps)
  end
  -- single keymap
  local desc, lhs, rhs = unpack(keymap, 1, 3)
  do -- type assertions
    local types = vim.tbl_map(type, { desc, lhs, rhs })
    assert(
      (types[1] == 'string' and
      types[2] == 'string' and
      (types[3] == 'string' or types[3] == 'function')),
      ('expected tuple (string, string, string|function). Got: (%s, %s, %s)')
        :format(types[1], types[2], types[3]))
  end
  return vim.tbl_deep_extend('keep', { lhs, rhs, desc = desc }, keymap)
end

---if cursor is on a word, call `fn` with <cWORD> as the first argument
---@param fn fun(word:string)
function M.cWORD(fn)
  local word = vim.fn.expand('<cWORD>')
  if not word or vim.fn.empty(word) == 1 then return end
  fn(word)
end

---if cursor is on a word, call `fn` with <cword> as the first argument
---@param fn fun(word:string)
function M.cword(fn)
  local word = vim.fn.expand('<cword>')
  if not word or vim.fn.empty(word) == 1 then return end
  fn(word)
end

---turn a function into one that works as an operator
---@param callback fun(positions:operatorPositions)
---@param _opts operatorOpts?
function M.operator(callback, _opts)
  local opts = _opts or {}

  local starting_window = vim.api.nvim_get_current_win()
  local cursor = fun.getcurpos()
  _G.op_fn = function ()
    local origin = vim.fn.getcurpos(0)
    local positions = {
      fun.line("'["), -- allow table to be used and unpacked as a tuple
      fun.line("']"),
      top     = fun.line("'["),
      bottom  = fun.line("']"),
      start   = fun.line("'["),
      ['end'] = fun.line("']"),
    }

    if cursor[2] == positions.bottom then
      positions['start'] = positions.bottom
      positions['end']   = positions.top
    end

    callback(positions)

    if opts.jump then
      local jump = opts.jump
      if jump == 'start' then
        -- jump to start of line where the motion was initiated
        cursor[2] = positions[jump]
        cursor[3] = fun.indent(cursor[2]) + 1
      elseif jump == 'top' then
        -- jump to start of line at the top of the range
        cursor[2] = positions[jump]
        cursor[3] = fun.indent(cursor[2]) + 1
      elseif jump == 'end' then
        -- jump to the start of the line at the end of the range
        cursor[2] = positions[jump]
        cursor[3] = fun.indent(cursor[2]) + 1
      elseif jump == 'bottom' then
        -- jump to the end of the line at the bottom of the range
        cursor[2] = positions[jump]
        cursor[3] = vim.v.maxcol
      elseif jump == 'origin' then
        vim.fn.setpos('.', origin)
      end
      api.nvim_win_set_cursor(starting_window, {cursor[2], cursor[3]})
    end
  end

  vim.go.operatorfunc = 'v:lua.op_fn'
  api.nvim_feedkeys("g@", "i", false)
end

---like `operator`, but callback function receives the lines within the operator positions
---@param callback fun(lines:string[])
---@param _opts operatorOpts?
function M.operator_over_lines(callback, _opts)
  return M.operator(function (positions)
    local s, e = positions.top, positions.bottom
    local lines = api.nvim_buf_get_lines(0, s - 1, e, false)
    callback(lines)
  end, _opts)
end

---perform `f` over visually selected range
---@param f fun(range:visualRange)
---@param _opts visualOpts?
function M.visual(f, _opts)
  local opts = _opts or {}

  -- leave visual mode so that '< and '> get set
  api.nvim_feedkeys(
    api.nvim_replace_termcodes('<esc>', true, false, true),
    'itx',
    false)

  local selection_type
  local visual_mode = vim.fn.visualmode(1)
  if visual_mode == 'V' then
    selection_type = 'line'
  elseif visual_mode == 'v' then
    selection_type = 'char'
  else
    selection_type = 'block'
  end

  local origin = vim.fn.getcurpos(0)

  local top = api.nvim_buf_get_mark(0, '<')
  local bottom = api.nvim_buf_get_mark(0, '>')
  assert(top[1] > 0, '< mark not set')
  assert(bottom[1] > 0, '> mark not set')

  local range = {
    top, -- allow table to be used and unpacked as a tuple
    bottom,
    top = top,
    bottom = bottom,
    selection_type = selection_type,
  }

  f(range)

  if opts.resume_visual then
    vim.cmd('normal gv')
    return
  end

  if opts.jump == 'top' then
    api.nvim_win_set_cursor(0, top)
  elseif opts.jump == 'bottom' then
    api.nvim_win_set_cursor(0, bottom)
  else
    vim.fn.setpos('.', origin)
  end
end

---like `visual`, but perform `f` over the lines in range
---@param f fun(lines:string[])
---@param _opts visualOpts?
function M.visual_over_lines(f, _opts)
  return M.visual(function (range)
    local s, e = range.top[1], range.bottom[1]
    local lines = api.nvim_buf_get_lines(0, s - 1, e, false)
    f(lines)
  end, _opts)
end

---search and replace in the given range
---@param s integer start of range
---@param e integer | '$' end of range
---@param pat string pattern to search for
---@param rep string replacement
---@param global boolean? replace multiple times per line (default: true)
function M.replace(s, e, pat, rep, global)
  assert(s,                   'beg required') assert(s > 0,               'beg must be positive')
  assert(e,                  'end required')
  assert(s > 0,               'beg must be positive')
  assert(pat,                 'search pattern required')
  assert(fun.empty(pat) == 0, 'search pattern cannot be empty')
  assert(rep,                 'replacement required')

  --- @type integer
  local _e
  if type(e) == 'string' and e == '$' then
    _e = fun.line('$')
  else
    _e = assert(tonumber(e), 'e must be a number')
  end

  if (s > _e) then s, _e = _e, s end
  if global == nil then global = true end
  local g = 'g'
  if global == false then g = '' end
  vim.cmd('keeppatterns '..s..','.._e..' s/'..pat..'/'..rep..'/e'..g)
end

---replace all occurrences of `<cword>` with `<prompt>` in current buffer
local function cword_prompt_replace()
  M.cword(function(word)
    prompt('Replace: ', function(response)
      if not response then return end
      M.replace(1, '$', '\\<' .. word .. '\\>', response)
    end)
  end)
end

---replace all occurrences of `<cword>` with `<prompt>` in `<motion>`
local function cword_operator_prompt_replace()
  M.cword(function(word)
    M.operator(function(positions)
      prompt('Replace: ', function(response)
        if not response then return end
        M.replace(positions.top, positions.bottom, '\\<' .. word .. '\\>', response)
      end)
    end, {jump = 'origin'})
  end)
end

---delete all lines containing `<cword>` in `<motion>`
local function cword_operator_delete_lines()
  M.cword(function(word)
    M.operator(function(positions)
      local range = positions.top..','..positions.bottom
      vim.cmd('keeppatterns '..range..'g/\\<'..word..'\\>/d _')
    end, {jump = 'origin'})
  end)
end

---replace all occurences of `<selection>` with `<prompt>` in buffer
local function visual_replace_prompt()
  M.visual(function(range)
    local end_col = range.bottom[2]
    if end_col == vim.v.maxcol then
      end_col = #(vim.fn.getline(range.bottom[1]))
    end

    local selected_lines = api.nvim_buf_get_text(0,
      (range.top[1]-1), (range.top[2]),
      (range.bottom[1]-1), (end_col+1), {})
    assert(#selected_lines > 0, 'No text selected')
    if (#selected_lines == 1) then
      assert(selected_lines[1] ~= '', 'Selected line is empty')
    end

    ---@type string
    local search_pattern
    do
      local joined = fun.join(selected_lines, '\n')
      local trimmed = fun.trim(joined, '\n')
      local escaped = fun.escape(trimmed, '/\\')
      if escaped == '' then
        return
      end
      search_pattern = escaped
    end

    prompt('Replace: ', function(response)
      M.replace(1, '$', search_pattern, response)
    end)
  end, {jump = 'origin'})
end

---append the lines in `<motion>` with `<prompt>`
local function operator_append_prompt()
  M.operator(function(positions)
    prompt('Append: ', function(response)
      M.replace(positions.top, positions.bottom, '$', response)
    end)
  end, {jump = 'origin'})
end

---append the selected lines with `<prompt>`
local function visual_append_prompt()
  M.visual(function(range)
    prompt('Append: ', function(response)
      M.replace(range.top[1], range.bottom[1], '$', response)
    end)
  end, {resume_visual = true})
end

---prepend  the selected lines with `<prompt>`
local function visual_prepend_prompt()
  M.visual(function(range)
    prompt('Prepend: ', function(response)
      M.replace(range.top[1], range.bottom[1], '^\\s*\\zs', response)
    end)
  end, {resume_visual = true})
end

---prepend the lines in `<motion>` with `<prompt>`
local function operator_prepend_prompt()
  M.operator(function(positions)
    prompt('Prepend: ', function(response)
      M.replace(positions.top, positions.bottom, '^\\s*\\zs', response)
    end)
  end, {jump = 'origin'})
end

---swap `<cline>` with the line at the end of the range
local function operator_swap_lines()
  M.operator(function(positions)
    local top, bottom = positions.top, positions.bottom
    local t_content, b_content = fun.getline(top), fun.getline(bottom)
    api.nvim_buf_set_lines(0, top-1, top, true, {b_content})
    api.nvim_buf_set_lines(0, bottom-1,  bottom,  true, {t_content})
  end, {jump = 'origin'})
end

---insert `<cline>` before the end of the range
local function operator_move_line()
  M.operator(function(positions)
    local start, _end = positions['start'], positions['end']
    if start == _end then return end

    local s_content = fun.getline(start)
    api.nvim_buf_set_lines(0, start-1, start, true, {})
    api.nvim_buf_set_lines(0, _end-1, _end-1,  true, {s_content})
  end, {jump = 'origin'})
end

local function toggle_concealcursor()
  local cc = 'nc'
  if vim.wo.concealcursor ~= '' then
    cc = ''
  end
  vim.wo.concealcursor = cc
end

local function echo(msg, fn)
  return function ()
    print(vim.inspect(msg))
    fn()
  end
end

local function yank(fn)
  return function()
    fun.setreg('"', fn())
  end
end

local function repeat_edit_on_next_line()
  local cursor = api.nvim_win_get_cursor(0)
  local row, col = unpack(cursor)
  api.nvim_win_set_cursor(0, { row + 1, col })
  vim.cmd.normal('.')
  api.nvim_win_set_cursor(0, { row + 1, col })
end

---delete the current buffer without closing the current window
---uses bwipeout to completely unlist and clear buffer from memory
---@param bang boolean true = force delete even if unsaved changes
local function buf_delete(bang)
  local sbang = bang and '!' or ''
  local ok, err = pcall(vim.cmd, ('b#|bwipeout%s #'):format(sbang)) ---@diagnostic disable-line
  if ok then return end
  local expected_errors = { 86, 23 }
  local is_err_expected = false
  for _, num in ipairs(expected_errors) do
    local s, _ = err:find(('E%d: '):format(num))
    if s then
      is_err_expected = true
      break
    end
  end
  if not is_err_expected then
    vim.notify('Unexpected error deleting buffer: ' .. err, vim.log.levels.ERROR, {})
    return
  end
  vim.cmd(('bp|bwipeout%s #'):format(sbang))
end

function M.setup()
  M.map {
    { mode = 'n', -- NORMAL MODE ===============================================
      { 'Move Cursor Down (visual line)', 'j', 'gj' },
      { 'Move Cursor Up (visual line)', 'k', 'gk' },
      { 'Scroll Up', '<c-e>', '3<c-e>' },
      { 'Scroll Down', '<c-y>', '3<c-y>' },
      { 'Jump or Scroll Up', '<c-u>',
        function()
          local cursor = vim.api.nvim_win_get_cursor(0)
          local first_visible = vim.fn.line('w0')
          local travel = math.floor(vim.api.nvim_win_get_height(0) / 2)
          local is_jump_within_view = (cursor[1]-1 - travel) < first_visible
          vim.cmd(('execute "normal! %d%s"') -- scroll with <c-y> or jump with k
            :format(travel, is_jump_within_view and '' or 'k'))
        end
      },
      { 'Jump or Scroll Up', '<c-d>',
        function()
          local cursor = vim.api.nvim_win_get_cursor(0)
          local last_visible = vim.fn.line('w$')
          local travel = math.floor(vim.api.nvim_win_get_height(0) / 2)
          local is_jump_within_view = (cursor[1]-1 + travel) > last_visible
          vim.cmd(('execute "normal! %d%s"') -- scroll with <c-e> or jump with j
            :format(travel, is_jump_within_view and '' or 'j'))
        end
      },
      { 'Open <cfile> (vsplit)', '<c-w><c-v>', cmd 'vertical wincmd f' },
      { 'Next Tab (Buf if only one tab)', ')',
        function()
          if #vim.api.nvim_list_tabpages() == 1 then
            vim.cmd('bnext')
          else
            vim.cmd('tabnext')
          end
        end
      },
      { 'Prev Tab (Buf if only one tab)', '(',
        function()
          if #vim.api.nvim_list_tabpages() == 1 then
            vim.cmd('bNext')
          else
            vim.cmd('tabNext')
          end
        end
      },
      { 'Run previous :command', leader ':', '@:' },
      { 'CD to <cfile> dir', leader '.', cmd "cd %:p:h | echo 'cd -> '.getcwd()" },
      { 'CD up one dir', leader ',', cmd "cd .. | echo 'cd -> '.getcwd()" },
      { 'Search <cword> without moving', leader '*', cmd 'let @/ = expand(\"<cword>\") .. \"\\\\>\" | set hlsearch' },
      { '<- Pasted Text', leader '<', 'V`]<' },
      { '-> Pasted Text', leader '>', 'V`]>' },
      { 'Buffer Delete',  leader 'bd', function() buf_delete(false) end },
      { 'Buffer Delete!', leader 'bD', function() buf_delete(true) end },
      { 'Buffer Only',    leader 'bo', cmd "execute \"silent! tabonly|silent! %bd|e#|bd#\" | echo 'Closed all buffers (and tabs) except current'" },
      { 'Quickfix Toggle', '<c-c>',
        function()
          for _, win in pairs(vim.fn.getwininfo()) do
            if win.quickfix == 1 then
              vim.cmd 'cclose'
              return
            end
          end

          -- Only open if there are items in the quickfix list
          if vim.fn.getqflist({size = 0}).size > 0 then
            vim.cmd 'copen'
          else
            vim.notify('Quickfix list is empty', vim.log.levels.INFO)
          end
        end
      },
      { 'Quickfix Next',      '<M-j>',   cmd 'cnext' },
      { 'Quickfix Next File', '<M-S-J>', cmd 'cnfile' },
      { 'Quickfix Prev',      '<M-k>',   cmd 'cprevious' },
      { 'Quickfix Prev File', '<M-S-K>', cmd 'cpfile' },
      { 'Append Section Marker', leader 'as', '0C<C-R>=repeat(\"=\",<Space>78)<CR><Esc>0R<C-R>\"<Space><Esc>' },
      { 'Append <prompt> to <motion>',  leader 'a', operator_append_prompt },
      { 'Prepend <prompt> to <motion>', leader 'i', operator_prepend_prompt },
      { 'Delete lines with <cword> in <motion>', leader 'd', cword_operator_delete_lines },
      -- TODO: I'd like to change this swap mapping to `<leader>[` and `<leader>]`
      -- I'd like it so that it can take a count before the [] key, or without
      -- a count it swaps with the line immediately above/below.
      { 'Swap <cline> with end of <motion>', leader 's', operator_swap_lines },
      { 'Move <cline> to the line before end of <motion>', leader 'm', operator_move_line },
      { 'Replace <cword> with <prompt> within <motion>', leader 'r', cword_operator_prompt_replace },
      { 'Replace <cword> with <prompt> (whole buffer)',  leader 'rr', cword_prompt_replace },
      { 'Quit (close window)', leader 'q', cmd 'q' },
      { 'Quit! (close window)', leader 'Q', cmd 'q!' },
      { 'Save file', leader 'w', cmd 'w' },
      { 'Toggle ConcealCursor', leader 'ot', toggle_concealcursor },
      { 'Yank File Contents', leader 'yy',
        echo('Yanked File Contents',
          yank(function () return api.nvim_buf_get_lines(0, 0, -1, true) end)) },
      { 'Yank File Name', leader 'yf',
        echo('Yanked File Name',
          yank(function () return fun.expand('%:t:r') end)) },
      { 'Yank File NAME', leader 'yF',
        echo('Yanked File NAME',
          yank(function () return fun.expand('%:t') end)) },
      { 'Yank File Path (absolute)', leader 'yp',
        echo('Yanked File Path (absolute)',
          yank(function () return fun.expand('%:p') end)) },
      { 'Yank Quote Register to System Clipboard', leader 'y<cr>', cmd 'let @+=@" | echo "Transfered To Clipboard"' },
      { 'Search Forward', 'n',
        function () local keys = { 'N', 'n' } return keys[(vim.v.searchforward+1)] end,
        { expr = true } },
      { 'Search Backward', 'N',
        function () local keys = { 'n', 'N' } return keys[(vim.v.searchforward+1)] end,
        { expr = true } },
      { 'Execute Q Macro', 'Q', '@q' },
      { 'Repeat Last Command On Next Line', 'S', 'j@:' },
      { 'Repeat Last Edit On Next Line', 's', repeat_edit_on_next_line },
      { 'Yank To The End Of The Line', 'Y', 'y$' },
      { 'Format To End Of Pasted Text', '=p', '=`]' },
      { 'Yank to system clipboard', 'gy', '"+y' },
      { 'Paste from system clipboard', 'gp', '"+p' },
      { '', '', '' },
    },
    { mode = 'i', -- INSERT MODE ===============================================
      { 'Move Cursor To The Start Of Line',   '<c-a>',      '<c-o>^' },
      { 'Move Cursor To The End Of Line',     '<c-e>',      '<c-o>$' },
      { 'Paste From System Clipboard',        '<c-r><c-r>', '<c-r>+', { silent = false } },
      { 'Insert a new line above the cursor', '<c-o><c-o>', '<c-o>O' },
      { 'Insert Current Line',                '<c-r><c-e>', "<c-r>=getline('.')<cr>" },
      { 'Insert Current File Name',           '<c-r><c-n>', "<c-r>=expand('%:t:r')<cr>" },
      { 'Insert Current File',                '<c-r><c-f>', "<c-r>=expand('%:t')<cr>" },
      { 'Insert Current File Path',           '<c-r><c-p>', "<c-r>=expand('%:p')<cr>" },
      { 'Insert CWD',                         '<c-r><c-d>', "<c-r>=getcwd()<cr>" },
      { '<- Current Line',                    '<c-d>',      '<c-o><<' },
      { '-> Current Line',                    '<c-t>',      '<c-o>>>' },
      { '', '', '' },
    },
    { mode = 'x', -- VISUAL MODE ===============================================
      { 'Run Normal-Mode Commands On Selection',      'N',         ':norm' },
      { 'Replace In Selected Range',                  'r',         ":<c-u>keeppatterns '<,'>s/", { silent = false } },
      { 'Replace Selection With <Prompt>',            leader('r'), visual_replace_prompt, { silent = false } },
      { 'Prepend <prompt> to Selected Lines',         'I',         visual_prepend_prompt, { silent = false } },
      { 'Append <prompt> to Selected Lines',          'A',         visual_append_prompt,  { silent = false } },
      { 'Format Text',                                'gq',        'gqgV' },
      { 'Search Forward For Selection',               '*',         ":<c-u>let @/=@\"<cr>gvy:let [@/,@\"]=[@\",@/]<cr>/\\V<c-r>=substitute(escape(@/,'/\\'),'\\n','\\\\n','g')<cr><cr>" },
      { 'Search Backward For Selection',              '#',         ":<c-u>let @/=@\"<cr>gvy:let [@/,@\"]=[@\",@/]<cr>/\\V<c-r>=substitute(escape(@/,'/\\'),'\\n','\\\\n','g')<cr><cr>NN" },
      { 'Search For Selection Without Moving Cursor', leader('*'), 'y:let @/ = \"<c-r>0\\\\>\"<cr>' },
      { 'Execute Last :Command',                      leader(':'), '@:' },
      { '', '', '' },
    },
    { mode = 'c', -- COMMANDLINE MODE ==========================================
      -- these mappings need to not be silent otherwise the command line does not
      -- visually update
      { 'Move Cursor To The Start Of Line', '<c-a>',      '<HOME>',                    { silent = false, } },
      { 'Move Cursor To The End Of Line',   '<c-e>',      '<END>',                     { silent = false, } },
      { 'Paste From System Clipboard',      '<c-r><c-r>', '<c-r>+',                    { silent = false, } },
      { 'Insert Current Line',              '<c-r><c-e>', "<c-r>=getline('.')<cr>",    { silent = false, } },
      { 'Insert Current File Name',         '<c-r><c-n>', "<c-r>=expand('%:t:r')<cr>", { silent = false, } },
      { 'Insert Current File',              '<c-r><c-f>', "<c-r>=expand('%:t')<cr>",   { silent = false, } },
      { 'Insert Current File Path',         '<c-r><c-p>', "<c-r>=expand('%:p')<cr>",   { silent = false, } },
      { 'Insert CWD',                       '<c-r><c-d>', "<c-r>=getcwd()<cr>",        { silent = false, } },
      { '', '', '' },
    },
    { mode = 't', -- TERMINAL MODE =============================================
      { '', '', '' },
    },
    { mode = 't', -- OPERATOR-PENDING MODE =====================================
      { '', '', '' },
    },
  }
end

M.prefix  = prefix
M.wrap    = wrap
M.leader  = leader
M.lleader = lleader
M.cmd     = cmd
M.lua     = lua

return M
