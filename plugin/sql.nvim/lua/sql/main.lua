local pkg_name = 'sql'
package.loaded[pkg_name] = { name = pkg_name }
local M = package.loaded[pkg_name]

---@param sql string|string[]
---@return string[] expanded_lines
function M.expand_where_clause(sql)
  local lines
  if type(sql) == 'string' then
    lines = vim.split(sql, '\n', { trimempty = true })
  else
    lines = sql
  end

  ---@param _str string string that may contain SQL keywords (WHERE|ON|AND)
  ---@return string str with leading keywords stripped out
  ---@return string? keyword that was stripped out if any
  local function strip_keywords(str)
    local _str = str
    local keyword
    local match

    match = { _str:find('^%s*[Ww][Hh][Ee][Rr][Ee]%s+') }
    if #match > 0 then
      _str = _str:sub(match[2]+1)
      keyword = 'WHERE'
    end

    match = { _str:find('^%s*[Oo][Nn]%s+') }
    if #match > 0 then
      _str = _str:sub(match[2]+1)
      keyword = 'ON'
    end

    match = { _str:find('^%s*[Aa][Nn][Dd]%s+') }
    if #match > 0 then
      _str = _str:sub(match[2]+1)
      keyword = 'AND'
    end

    return _str, keyword
  end

  local function expand_predicates(str)
    local match
    match = { str:find('^%s*([%w_]+)%s+([%w_]+)%s+(%S.-)%s*$') }
    if #match < 1 then
      return { str }
    end
    local predicates = {}
    local t1 = match[3]
    local t2 = match[4]
    local columns = vim.split(match[5], ',')
    for _, column in ipairs(columns) do
      local cols = vim.split(column, ':', { trimempty = true })
      table.insert(predicates,
        ('%s.%s = %s.%s'):format(t1, cols[1], t2, cols[2] or cols[1]))
    end
    return predicates
  end

  local indent = lines[1]:match('^%s*') or ''
  local _, first_keyword = strip_keywords(lines[1])
  local expanded_lines = {}
  for _, line in ipairs(lines) do
    local _line, keyword = strip_keywords(line)
    local predicates = expand_predicates(_line)
    for _, predicate in ipairs(predicates) do
      if #expanded_lines == 0 then
        keyword = first_keyword or 'ON'
      else
        keyword = first_keyword == 'WHERE' and '  AND' or 'AND'
      end
      table.insert(expanded_lines, ('%s%s %s'):format(indent, keyword, predicate))
    end
  end

  return expanded_lines
end


---format lines in range such that the commas are at the beginning of lines
---with an extra space before the first comma
---@param start_line integer 1-based start of range (inclusive)
---@param end_line   integer 1-based end of range (inclusive)
function M.fix_commas(start_line, end_line)
  local mods = "silent keeppatterns "
  -- ensure that the first line has a space at the beginning to line it up
  -- with the commas on the following lines
  vim.cmd(mods .. start_line .. "s/\\(^\\|^\\(\\t\\| \\{4\\}\\)\\+\\)\\zs[^[:space:],]/ &/e")
  -- prepend commas to all but the first line
  vim.cmd(mods .. start_line+1 .. "," .. end_line  .. "s/^\\s*\\zs[^[:space:],]/,&/e")
  -- remove trailing commas
  vim.cmd(mods .. start_line .. "," .. end_line  .. "s/,\\s*$//e")
end

---expand column shorthand into an aliased column or variable assignment
---- ""                     -> "NULL"
---- "value"                -> "value"
---- "value:ident"          -> "[ident] = value"
---- "tbl.value:ident"      -> "[ident] = tbl.value"
---- "value:"               -> "[value] = value"
---- "tbl.value:"           -> "[value] = tbl.value"
---- ":ident"               -> "[ident] = NULL"
---- "'value:ident':alias"  -> "[alias] = 'value:ident'"
---- "usr.name@username"    -> "@username = usr.name"
---- "@username"            -> "@username = NULL"
---- "username@"            -> "@username = username"
---- "usr.name@"            -> "@name = usr.name"
---- "@in_wh_id@in_vchWhID" -> "@in_vchWhID = @in_wh_id"
---@param str string
---@return string
local function sql_expand_column(str)
  assert(str, "argument `str` is required")
  local col = vim.fn.trim(str)
  if col == "" then return "NULL" end

  local iscolumn = vim.fn.match(col, ":") > -1
  local isassign = vim.fn.match(col, "@") > -1

  local isstring = vim.fn.match(col, "'") == 0 or vim.fn.match(col, "N'") == 1
  local string_end
  if isstring then
    string_end = vim.fn.match(col, "'", 0, 2)
    iscolumn = vim.fn.match(col, ":", string_end) > -1
    isassign = vim.fn.match(col, "@", string_end) > -1
  end

  if not iscolumn and not isassign then return col end

  local sep
  if iscolumn then
    sep = ":"
  elseif isassign then
    sep = "@"
  end

  local value, ident
  if isstring then
    if vim.fn.match(col, sep, string_end) == -1 then return col end
    value = vim.fn.slice(col, 0, string_end+1)
    ident = vim.fn.slice(col, vim.fn.match(col, sep, string_end+1)+1)
  else
    if vim.fn.match(col, sep) == -1 then return col end
    local sep_index = vim.fn.match(col, sep)
    if vim.fn.count(col, sep) > 1 then
      sep_index = vim.fn.match(col, sep, 2)
    end
    value = vim.fn.slice(col, 0, sep_index)
    ident = vim.fn.slice(col, vim.fn.match(col, sep, sep_index)+1)
  end

  if ident == "" then
    local field = vim.fn.split(value, "\\.")
    ident = field[#field]
  end

  if value == "" then
    value = "NULL"
  end

  if iscolumn then
    return "["..ident.."] = " .. value
  end
  return "@"..ident.. " = " .. value
end

---unit tests for sql_expand_column()
---@return boolean
---@see sql_expand_column
local function test_sql_expand_column()
  local test = require('util').test
  return test("sql_expand_column", sql_expand_column, {
    { input = "",                     expected = "NULL" },
    { input = "value",                expected = "value" },
    { input = "value:ident",          expected = "[ident] = value" },
    { input = "tbl.value:ident",      expected = "[ident] = tbl.value" },
    { input = "value:",               expected = "[value] = value" },
    { input = "tbl.value:",           expected = "[value] = tbl.value" },
    { input = ":ident",               expected = "[ident] = NULL" },
    { input = "'value:ident':alias",  expected = "[alias] = 'value:ident'" },
    { input = "usr.name@username",    expected = "@username = usr.name" },
    { input = "@username",            expected = "@username = NULL" },
    { input = "username@",            expected = "@username = username" },
    { input = "usr.name@",            expected = "@name = usr.name" },
    { input = "@in_wh_id@in_vchWhID", expected = "@in_vchWhID = @in_wh_id" },
  })
end

---expand a line of shorthand columns into a full list of columns
---@param line string
---@return string[]
local function sql_expand_select_columns(line)
  assert(line, "text not provided")
  local text = vim.fn.trim(line)
  assert(vim.fn.match(text, "\n") == -1, "only one line should be provided")

  if #text == 0 then return {} end

  local expanded_lines = {}
  local columns = vim.fn.split(text, ",", true)
  for i, col in ipairs(columns) do
    local prefix = ","
    if i == 1 then prefix = " " end
    local c = assert(sql_expand_column(col), "error expanding col: '"..col.."'" )
    table.insert(expanded_lines, prefix .. c)
  end

  return expanded_lines
end

---unit tests for sql_expand_select_columns
---@return boolean
---@see sql_expand_select_columns
local function test_sql_expand_select_columns()
  local test = require('util').test
  return test("sql_expand_select_columns", sql_expand_select_columns, {
    { input = "", expected = {} },
    { input = "hello", expected = { " hello" } },
    { input = "hello,world", expected = { " hello", ",world" } },
    { input = "\thello, world", expected = { " hello", ",world" } },
    { input = "hello,'hello,world':msg", expected = { ",[msg] = 'hello,world']" } },
  })
end

---expand the select columns on the current line
---@see sql_expand_select_columns
local function expand_cols_cur_line()
  local linenum = vim.fn.line(".")
  local text = vim.fn.getline(linenum)
  local lines = require('util').indent_lines(sql_expand_select_columns(text))
  if #lines == 0 then return end

  -- setting undolevels (even to itself) sets an undo-break so that pressing
  -- `u` in normal mode will undo the expansion.
  vim.bo.undolevels = vim.bo.undolevels
  vim.api.nvim_buf_set_lines(0, vim.fn.line(".")-1, vim.fn.line("."), false, lines)
  vim.api.nvim_win_set_cursor(0, {linenum+(#lines-1), vim.v.maxcol})
end

local default_opts = {}

function M.setup(opts)
  M.opts = vim.tbl_deep_extend('keep', opts or {}, default_opts)
  return M
end

return M
