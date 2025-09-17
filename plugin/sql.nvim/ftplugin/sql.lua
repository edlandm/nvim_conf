vim.keymap.set({ 'n', 'i' }, '<Plug>(SqlExpandWhere)', function()
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
end)

vim.keymap.set({ 'x' }, '<Plug>(SqlExpandWhere)', function()
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

vim.keymap.set({ 'x' }, '<Plug>(SqlFixCommas)', function()
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
