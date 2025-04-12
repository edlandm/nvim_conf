local api = vim.api
local fun = vim.fn
local util = require('util')
local prompt = util.prompt

local M = {}

--- @alias abbrev_mode 'ia' | 'ca' | '!a'
--- @alias mode 'n' | 'i' | 'x' | 't' | 'c' | 'l' | 'v' | 's' | 'o' | abbrev_mode
--- @alias desc string
--- @alias lhs string
--- @alias rhs string | function
--- @alias mapping [ desc, lhs, rhs, vim.keymap.set.Opts? ]
--- @alias mapfn fun(mappings: mapping[], _buffer?: boolean):nil

--- @alias jumpDest 'start' | 'end' | 'top' | 'bottom' | 'origin'
--- @alias operatorOpts { jump:jumpDest? }
--- @alias operatorPositions { top:integer, bottom:integer, start:integer, end:integer }
--- @alias visualOpts { jump:'top'|'bottom'|'origin'?, resume_visual:boolean? }
--- @alias position [integer, integer]
--- @alias selectionType 'char' | 'line' | 'block
--- @alias visualRange { top:position, bottom:position, selection_type:selectionType }

---- Utility Functions
---function for making shortcut functions for making mappings
---@param mode mode
---@return mapfn
local function map_fn(mode)
  return function (mappings, _buffer)
    local buffer = _buffer or false
    for _, m in ipairs(mappings) do
      local desc, lhs, rhs, opts = unpack(m)
      local defaults = { desc = desc, noremap = true, silent = true, expr = false }
      opts = vim.tbl_deep_extend('keep', opts or {}, defaults)

      assert(fun.empty(desc) == 0, 'mapping description required')
      assert(fun.empty(lhs)  == 0, 'mapping lhs required')
      assert(fun.empty(rhs)  == 0, 'mapping rhs required')

      if type(rhs) == 'function' then
        opts.callback = rhs
        rhs = ''
      end

      if buffer then
        api.nvim_buf_set_keymap(0, mode, lhs, rhs, opts)
      else
        api.nvim_set_keymap(mode, lhs, rhs, opts)
      end
    end
  end
end

M.nmap = map_fn('n') -- normal
M.imap = map_fn('i') -- insert
M.xmap = map_fn('x') -- visual
M.tmap = map_fn('t') -- terminal
M.cmap = map_fn('c') -- command-line
M.omap = map_fn('o') -- operator-pending mode

---prepend `s` with `<leader>`
---@param s string
---@return string
function M.leader(s)
  return ('<leader>%s'):format(s)
end

---prepend `s` with `<localleader>`
---@param s string
---@return string
function M.lleader(s)
  return ('<localleader>%s'):format(s)
end

---wrap string in <cmd><cr>
---@param s any
---@return string
function M.cmd(s)
  return ('<cmd>%s<cr>'):format(s)
end

---wrap string in <cmd>lua <cr>
---@param s any
---@return string
function M.lua(s)
  return ('<cmd>lua %s<cr>'):format(s)
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
    local positions = {
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
      --[[
      elseif jump == 'origin' then
        jump to position where cursor was before the operation
        only necessary if the operatorfunc moved the cursor
      --]]
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

---- Normal Mode =============================================================
-- Functions =================================================================
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

function M.setup()
  local cmd = M.cmd
  local leader = M.leader
  M.nmap({
    { 'Move Cursor Down (visual line)', 'j', 'gj' },
    { 'Move Cursor Up (visual line)', 'k', 'gk' },
    { 'Scroll Up', '<c-e>', '3<c-e>' },
    { 'Scroll Down', '<c-y>', '3<c-y>' },
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
    { 'Buffer Delete',  leader 'bd', cmd 'b#|bwipeout #' },
    { 'Buffer Delete!', leader 'bD', cmd 'b#|bwipeout! #' },
    { 'Buffer Only',    leader 'bo', cmd "execute \"silent! tabonly|silent! %bd|e#|bd#\" | echo 'Closed all buffers (and tabs) except current'" },
    { 'Quickfix Next',      '<M-j>',   cmd 'cnext' },
    { 'Quickfix Next File', '<M-S-J>', cmd 'cnfile' },
    { 'Quickfix Prev',      '<M-k>',   cmd 'cprevious' },
    { 'Quickfix Prev File', '<M-S-K>', cmd 'cpfile' },
    -- fallbacks in the event that the terminal doesn't support <M-S-*> mappings
    { 'Quickfix Next',      leader 'cn', cmd 'cnext' },
    { 'Quickfix Next File', leader 'cN', cmd 'cnfile' },
    { 'Quickfix Prev',      leader 'cp', cmd 'cprevious' },
    { 'Quickfix Prev File', leader 'cP', cmd 'cpfile' },
    { 'Append Session Marker', leader 'as', '0C<C-R>=repeat(\"=\",<Space>78)<CR><Esc>0R<C-R>\"<Space><Esc>' },
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
  })
  ---- Insert Mode =============================================================
  M.imap({
    { 'Move Cursor To The Start Of Line',   '<c-a>',      '<c-o>^' },
    { 'Move Cursor To The End Of Line',     '<c-e>',      '<c-o>$' },
    { 'Paste From System Clipboard',        '<c-r><c-r>', '<c-r>+', { silent = false } },
    { 'Insert a new line above the cursor', '<c-o><c-o>', '<c-o>O' },
    { 'Insert Current Line',                '<c-r><c-e>', "<c-r>=getline('.')<cr>" },
    { 'Insert Current File Name',           '<c-r><c-n>', "<c-r>=expand('%:t:r')<cr>" },
    { 'Insert Current File',                '<c-r><c-f>', "<c-r>=expand('%:t')<cr>" },
    { 'Insert Current File Path',           '<c-r><c-p>', "<c-r>=expand('%:p')<cr>" },
    { '<- Current Line',                    '<c-d>',      '<c-o><<' },
    { '-> Current Line',                    '<c-t>',      '<c-o>>>' },
  })
  ---- Visual Mode =============================================================
  M.xmap({
    { 'Run Normal-Mode Commands On Selection',      'N',         ':norm' },
    { 'Replace In Selected Range',                  'r',         ":<c-u>keeppatterns '<,'>s/", { silent = false } },
    { 'Replace Selection With <Prompt>',            leader('r'), visual_replace_prompt, { silent = false } },
    { 'Prepend <prompt> to Selected Lines',         'I',         visual_prepend_prompt, { silent = false } },
    { 'Append <prompt> to Selected Lines',          'A',         visual_append_prompt,  { silent = false } },
    { 'Search Forward For Selection',               '*',         ":<c-u>let @/=@\"<cr>gvy:let [@/,@\"]=[@\",@/]<cr>/\\V<c-r>=substitute(escape(@/,'/\\'),'\\n','\\\\n','g')<cr><cr>" },
    { 'Search Backward For Selection',              '#',         ":<c-u>let @/=@\"<cr>gvy:let [@/,@\"]=[@\",@/]<cr>/\\V<c-r>=substitute(escape(@/,'/\\'),'\\n','\\\\n','g')<cr><cr>NN" },
    { 'Search For Selection Without Moving Cursor', leader('*'), 'y:let @/ = \"<c-r>0\\\\>\"<cr>' },
    { 'Execute Last :Command',                      leader(':'), '@:' },
  })
  ---- Terminal Mode ===========================================================
  M.tmap({
    { 'Normal Mode',         '<esc><esc>', '<c-\\><c-n>' },
    { 'Switch Window Up',    '<c-k>',      '<c-\\><c-n><c-w>k' },
    { 'Switch Window Down',  '<c-j>',      '<c-\\><c-n><c-w>j' },
    { 'Switch Window Left',  '<c-h>',      '<c-\\><c-n><c-w>h' },
    { 'Switch Window Right', '<c-l>',      '<c-\\><c-n><c-w>l' },
  })
  ---- Command-line Mode =======================================================
  M.cmap({
    -- these mappings need to not be silent otherwise the command line does not
    -- visually update
    { 'Move Cursor To The Start Of Line', '<c-a>',      '<HOME>',                    { silent = false, } },
    { 'Move Cursor To The End Of Line',   '<c-e>',      '<END>',                     { silent = false, } },
    { 'Paste From System Clipboard',      '<c-r><c-r>', '<c-r>+',                    { silent = false, } },
    { 'Insert Current Line',              '<c-r><c-e>', "<c-r>=getline('.')<cr>",    { silent = false, } },
    { 'Insert Current File Name',         '<c-r><c-n>', "<c-r>=expand('%:t:r')<cr>", { silent = false, } },
    { 'Insert Current File',              '<c-r><c-f>', "<c-r>=expand('%:t')<cr>",   { silent = false, } },
    { 'Insert Current File Path',         '<c-r><c-p>', "<c-r>=expand('%:p')<cr>",   { silent = false, } },
  })
  ---- Operator-Pending Mode ===================================================
  M.omap({
  })
end

return M
