-- vim:fdm=marker
-- {{{ Settings ==============================================================
local setopts = require('settings').setopts

setopts('o', {
  { 'shiftround', false },
})

setopts('wo', {
  { 'foldmethod', 'indent' },
  { 'foldignore', '' },
})

setopts('bo', {
  'expandtab',
  { 'commentstring', '--\\ %s' },
  { 'shiftwidth',    4 },
  { 'suffixesadd',   '.sql' },
  { 'tabstop',       4 },
})
-- }}}
-- {{{ Functions
local test = require('util').test
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
local function sql_expand_column(str) -- {{{
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
end -- }}}
---unit tests for sql_expand_column()
---@return boolean
---@see sql_expand_column
local function test_sql_expand_column() -- {{{
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
end -- }}}
---expand a line of shorthand columns into a full list of columns
---@param line string
---@return string[]
local function sql_expand_select_columns(line) -- {{{
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
end -- }}}
---unit tests for sql_expand_select_columns
---@return boolean
---@see sql_expand_select_columns
local function test_sql_expand_select_columns() -- {{{ () -> bool
  return test("sql_expand_select_columns", sql_expand_select_columns, {
    { input = "", expected = {} },
    { input = "hello", expected = { " hello" } },
    { input = "hello,world", expected = { " hello", ",world" } },
    { input = "\thello, world", expected = { " hello", ",world" } },
    { input = "hello,'hello,world':msg", expected = { ",[msg] = 'hello,world']" } },
  })
end -- }}}
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
---rename a sql variable without moving the cursor
---@param old string
---@param new string
local rename_var = function(old, new) -- {{{
  local cursor = vim.fn.getpos(".")
  vim.cmd("keeppatterns %s/@\\zs" .. old .. "\\ze\\>/" .. new .. "/g")
  vim.fn.setpos(".", cursor)
end -- }}}
-- }}}
-- {{{ Operator Functions
_G.sql_snake_case_cword = function() -- {{{
  local old = vim.fn.expand("<cword>")
  assert(#old > 0, "cursor not on a word")
  vim.cmd.normal('crs') -- coerce to snake_case
  local snek = vim.fn.expand("<cword>")
  assert(#snek > 0, "failed to convert to snake_case")
  vim.cmd.undo()
  rename_var(old, snek)
  -- setting the operatorfunc allows this function to be dot-repeatable
  -- NOTE: this needs to be last because the coerce command also sets the operatorfunc
  vim.go.operatorfunc = "v:lua.sql_snake_case_cword"
end -- }}}
-- }}}
-- {{{ commands ==============================================================
---shorthand for creating buffer-local user commands
---@param name string
---@param desc string
---@param fn function
---@param _opts? vim.api.keyset.cmd_opts
local function user_cmd(name, desc, fn, _opts)
  local opts = vim.tbl_deep_extend('keep', {desc = desc}, (_opts or {}))
  vim.api.nvim_buf_create_user_command(0, name, fn, opts)
end

---create a function that runs a vim command over a range
---@param cmd string
---@return fun(opts:any)
local range_cmd = function(cmd)
  return function(opts)
    vim.cmd('keeppatterns ' .. opts.line1 .. ','  .. opts.line2 .. cmd)
  end
end

user_cmd('SqlAssignColumnsToVariables',
  'Assign columns (in a SELECT statement) to variables',
  range_cmd('s/\\(\\w\\{-}\\.\\)\\(\\S\\+\\)$/@\\2 = &/e'),
  { range = true })

user_cmd('SqlWhereMatchColumnsToVariables',
  'Match columns (in a WHERE clause) to variables',
  range_cmd('v/=/s/\\(\\w\\{-}\\.\\)\\(\\S\\+\\)$/& = @\\2/e'),
  { range = true })

user_cmd('SqlVarsToInParams',
  'Convert variables to @in_ parameters',
  range_cmd('s/@/@in_/ge'),
  { range = true })

user_cmd('SqlVarsToOutParams',
  'Assign variables to @out_ parameters',
  range_cmd('s/@\\S\\+/@out_& = &/ge'),
  { range = true })

-- automatically give [aliases] to all highlighted columns
-- SELECT                     -> SELECT
--    @pick_id                ->    [@pick_id]          = @pick_id
--   ,@pick_qty_in_tote       ->   ,[@pick_qty_in_tote] = @pick_qty_in_tote
user_cmd('SqlSelectAliases',
  'Generate colums aliases (in a SELECT statement)',
  range_cmd('s/\\s*,\\?\\zs\\(\\w\\+\\.\\)\\?\\(@\\?\\w\\+\\)/[\\2] = \\1\\2/e'),
  { range = true })

user_cmd("SqlFixCommas",
  "Add commas to the beginning of each line of a list of columns in a SELECT statement",
  function(opts)
    -- I prefer commas at the beginning of lines
    local mods = "silent keeppatterns "
    local l1 = opts.line1
    local l2 = opts.line2
    -- ensure that the first line has a space at the beginning to line it up
    -- with the commas on the following lines
    vim.cmd(mods .. l1 .. "s/\\(^\\|^\\(\\t\\| \\{4\\}\\)\\+\\)\\zs[^[:space:],]/ &/e")
    -- prepend commas to all but the first line
    vim.cmd(mods .. l1+1 .. "," .. l2 .. "s/^\\s*\\zs[^[:space:],]/,&/e")
    -- remove trailing commas
    vim.cmd(mods .. l1 .. "," .. l2 .. "s/,\\s*$//e")
  end,
  { range = true, })

user_cmd("SqlFixStrings",
  "Add the N prefix to every string that is missing it in the current buffer",
  function()
  -- NOTE: this pattern is imperfect; if multiple strings are on the same
  -- line, the following ones will have N prepended to their closing quote.
  -- I do not think there is a fix for that using regular expressions.
  local pattern = "[^N]\\zs'\\ze[^']\\{-\\}'"
  vim.cmd("keeppatterns %s/" .. pattern .. "/N&/e")
end)

user_cmd("SqlSuggestNolocks",
  "Find every FROM without a NOLOCK and offer to add it (not perfect)",
  function ()
    local pattern = "FROM [^)]\\{-\\} \\zs\\ze\\(WHERE\\|\\n\\)"
    vim.cmd("keeppatterns %s/" .. pattern .. "/WITH (NOLOCK) /ce")
  end)

user_cmd("SqlRenameVariable",
  "Rename a sql variable in the current buffer",
  function(opts)
    ---@type string
    local old, new
    if #opts.fargs == 2 then
      old = opts.fargs[1]
      new = opts.fargs[2]
    elseif #opts.fargs == 1 then
      old = opts.fargs[1]
      new = vim.fn.input("Rename @" .. old .. " to: ")
    elseif #opts.fargs == 0 then
      old = vim.fn.expand("<cword>")
      new = vim.fn.input("Rename @" .. old .. " to: ")
    else
      assert(false, "invalid number of arguments")
    end
    assert(#old > 0, "invalid target variable")
    assert(#new > 0, "invalid new name provided")
    rename_var(old, new)
  end,
  { nargs = "*", })
-- }}}
-- {{{ mappings
-- {{{ INSERT ================================================================
require('mappings').imap({
  { 'expand: AND',                    'A<tab>',  'AND<space>' },
  { 'expand: CASE WHEN...END',        'C<tab>',  'CASE<space>WHEN<esc>o<tab>END<esc>kA<space>' },
  { 'expand: CONVERT',                'CR<tab>', 'CONVERT()<left>' },
  { 'expand: DECLARE',                'D<tab>',  'DECLARE<cr><tab>' },
  { 'expand: FROM t_',                'F<tab>',  'FROM t_' },
  { 'expand: GROUP BY',               'G<tab>',  'GROUP BY<cr><tab> ' },
  { 'expand: HAVING',                 'H<tab>',  'HAVING<tab>' },
  { 'expand: INSERT INTO',            'I<tab>',  'INSERT<space>INTO' },
  { 'expand: LEFT OUTER JOIN t_ ON',  'L<tab>',  'LEFT<space>OUTER<space>JOIN<space>t_<cr>ON<tab><esc>>>kA' },
  { 'expand: INNER JOIN t_ ON',       'N<tab>',  'INNER<space>JOIN<space>t_<cr>ON<tab><esc>>>kA' },
  { 'expand: ORDER BY',               'O<tab>',  'ORDER<space>BY<cr><tab>' },
  { 'expand: PARTITION BY',           'P<tab>',  'PARTITION<space>BY<space>' },
  { 'expand: SELECT 1',               'SS<tab>', 'SELECT 1' },
  { 'expand: SELECT TOP 1',           'ST<tab>', 'SELECT TOP 1<cr><tab>' },
  { 'expand: SELECT',                 'S<tab>',  'SELECT<cr><tab> ' },
  { 'expand: UPDATE',                 'U<tab>',  'UPDATE<space><cr>SET<tab><esc>kA' },
  { 'expand: OVER ()',                'V<tab>',  'OVER<space>()<left>' },
  { 'expand: WHERE',                  'W<tab>',  'WHERE<space>' },
  { 'expand: WITH (NOLOCK)',          'WN',      'WITH<space>(NOLOCK)' },
  { 'expand SELECT column shorthand', '<c-s>',   expand_cols_cur_line },
}, true)
-- }}}
-- {{{ NORMAL ================================================================
local lleader = require('mappings').lleader
require('mappings').nmap({
  { 'Swap WHERE operands', lleader('so'), '<cmd>!sql mappredicate sio<cr>'},
  -- table definitions can take the form of
  -- @table_var_name(field1, field2)
  -- #temp_table_name(field1, field2)
  -- or
  -- @table_var_name:field1, field2
  -- #temp_table_name:field1, field2
  { 'Expand Table Definition (#temp or @variable)', lleader('et'), '<cmd>.!prodb expand table<cr>' },
  { 'Rename Variable (<cword>)', lleader('rv'), '<cmd>SqlRenameVariable<cr>' },
  { 'Convert <cword> to snake_case', lleader('cs'), _G.sql_snake_case_cword },
  -- { '', lleader(''), '' },
}, true)
-- }}}
-- {{{ VISUAL ================================================================
require('mappings').xmap({
  -- TODO: find a way to do this with Treesitter
  { 'Uppercase SQL keywords', lleader('U'), '!sql uppercase<cr>' },
  { 'Generate colums aliases (in a SELECT statement)', lleader('sa'), ':SqlSelectAliases<cr>' },
  { 'Format commas in SQL list', lleader('fc'), ':SqlFixCommas<cr>' },
  { 'Assign columns (in a SELECT statement) to variables', lleader('sv'), ':SqlAssignColumnsToVariables<cr>' },
  { 'Match columns (in a WHERE clause) to variables', lleader('wv'), ':SqlWhereMatchColumnsToVariables<cr>' },
  { 'Convert variables to @in_ parameters', lleader('vi'), ':SqlVarsToInParams<cr>' },
  { 'Convert variables to @out_ parameters', lleader('vi'), ':SqlVarsToOutParams<cr>' },
}, true)
-- }}}
-- }}}
