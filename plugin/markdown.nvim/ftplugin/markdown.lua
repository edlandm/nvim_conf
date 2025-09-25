---turn a function into one that works as an operator
---@param callback fun(positions:operatorPositions)
---@param _opts operatorOpts?
local function operator(callback, _opts)
  local opts = _opts or {}

  local starting_window = vim.api.nvim_get_current_win()
  local cursor = vim.fn.getcurpos()
  _G.op_fn = function ()
    local origin = vim.fn.getcurpos(0)
    local positions = {
      vim.fn.line("'["), -- allow table to be used and unpacked as a tuple
      vim.fn.line("']"),
      top     = vim.fn.line("'["),
      bottom  = vim.fn.line("']"),
      start   = vim.fn.line("'["),
      ['end'] = vim.fn.line("']"),
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
        cursor[3] = vim.fn.indent(cursor[2]) + 1
      elseif jump == 'top' then
        -- jump to start of line at the top of the range
        cursor[2] = positions[jump]
        cursor[3] = vim.fn.indent(cursor[2]) + 1
      elseif jump == 'end' then
        -- jump to the start of the line at the end of the range
        cursor[2] = positions[jump]
        cursor[3] = vim.fn.indent(cursor[2]) + 1
      elseif jump == 'bottom' then
        -- jump to the end of the line at the bottom of the range
        cursor[2] = positions[jump]
        cursor[3] = vim.v.maxcol
      elseif jump == 'origin' then
        vim.fn.setpos('.', origin)
      end
      vim.api.nvim_win_set_cursor(starting_window, {cursor[2], cursor[3]})
    end
  end

  vim.go.operatorfunc = 'v:lua.op_fn'
  vim.api.nvim_feedkeys("g@", "i", false)
end

vim.keymap.set({ 'n' }, '<Plug>(MarkdownAddListItem)', function()
  require('markdown').add_list_item({ append_at = 'item' })
  vim.cmd([[startinsert!]])
end, { noremap = true, silent = true })

vim.keymap.set({ 'i' }, '<Plug>(MarkdownAddListItem)', function()
  require('markdown').add_list_item({ append_at = 'item' })
end, { noremap = true, silent = true })

vim.keymap.set({ 'n' }, '<Plug>(MarkdownAppendListItem)', function()
  require('markdown').add_list_item({ append_at = 'list' })
  vim.cmd([[startinsert!]])
end, { noremap = true, silent = true })

vim.keymap.set({ 'i' }, '<Plug>(MarkdownAppendListItem)', function()
  require('markdown').add_list_item({ append_at = 'list' })
end, { noremap = true, silent = true })

vim.keymap.set({ 'n' }, '<Plug>(MarkdownAddTask)', function()
  require('markdown').add_task({ append_at = 'item' })
end, { noremap = true, silent = true })

vim.keymap.set({ 'i' }, '<Plug>(MarkdownAddTask)', function()
  require('markdown').add_task({ append_at = 'item' })
end, { noremap = true, silent = true })

vim.keymap.set({ 'n' }, '<Plug>(MarkdownAppendTask)', function()
  require('markdown').add_task({ append_at = 'list' })
  vim.cmd([[startinsert!]])
end, { noremap = true, silent = true })

vim.keymap.set({ 'i' }, '<Plug>(MarkdownAppendTask)', function()
  require('markdown').add_task({ append_at = 'list' })
end, { noremap = true, silent = true })

--[[
vim.keymap.set({ 'n' }, '<Plug>Markdown)', function()
  local cur_pos = vim.api.nvim_win_get_cursor(0)
  operator(function(range)
    local lines = vim.api.nvim_buf_get_lines(0, range[1]-1, range[2], true)

    local results = require('sql').expand_where_clause(lines)
    if not results or #results < 1 then
      vim.notify('sql.expand_where_clause did not return any results', vim.log.levels.WARN, {})
      vim.api.nvim_win_set_cursor(0, cur_pos)
      return
    end

    -- jump cursor to the end of the expansion
    local pos = {
      range[1] + #results - 1,
      #results[#results]
    }

    vim.api.nvim_buf_set_lines(0, range[1]-1, range[1], true, results)
    vim.api.nvim_win_set_cursor(0, pos)
  end, { jump = 'origin' })
end, { noremap = true, silent = true })

vim.keymap.set({ 'i' }, '<Plug>Markdown)', function()
  local cur_pos = vim.api.nvim_win_get_cursor(0)
  local start_line = cur_pos[1]
  local line = vim.api.nvim_get_current_line()

  local results = require('sql').expand_where_clause({ line })
  if not results or #results < 1 then
    vim.notify('sql.expand_where_clause did not return any results', vim.log.levels.WARN, {})
    return
  end

  cur_pos[1] = cur_pos[1] + #results - 1
  cur_pos[2] = #results[#results]

  vim.api.nvim_buf_set_lines(0, start_line-1, start_line, true, results)
  vim.api.nvim_win_set_cursor(0, cur_pos)
end, { noremap = true, silent = true })

vim.keymap.set({ 'x' }, '<Plug>Markdown)', function()
  local cur_pos = vim.api.nvim_win_get_cursor(0)

  -- leave visual mode so that '< and '> get set
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes('<esc>', true, false, true),
    'itx',
    false)

  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")

  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local results = require('sql').expand_where_clause(lines)
  if not results or #results < 1 then
    vim.notify('sql.expand_where_clause did not return any results', vim.log.levels.WARN, {})
    return
  end

  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, true, results)

  -- move cursor to end of the expansion
  cur_pos[1] = start_line + #results - 1
  cur_pos[2] = #results[#results]

  vim.api.nvim_win_set_cursor(0, cur_pos)
end, { noremap = true, silent = true })

vim.keymap.set({ 'n' }, '<Plug>Markdown)', function()
  operator(function(range)
    require('sql').fix_commas(unpack(range))
  end, { jump = 'origin' })
end, { noremap = true, silent = true })

vim.keymap.set({ 'x' }, '<Plug>Markdown)', function()
  local cur_pos = vim.api.nvim_win_get_cursor(0)

  -- leave visual mode so that '< and '> get set
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes('<esc>', true, false, true),
    'itx',
    false)

  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")

  require('sql').fix_commas(start_line, end_line)
end, { noremap = true, silent = true })
--]]
