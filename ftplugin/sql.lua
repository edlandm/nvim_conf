-- vim:fdm=marker
-- {{{ buffer settings
vim.cmd.setlocal("commentstring=--\\ %s")
vim.cmd.setlocal("expandtab")
vim.cmd.setlocal("foldignore=")
vim.cmd.setlocal("foldmethod=indent")
vim.cmd.setlocal("noshiftround")
vim.cmd.setlocal("shiftwidth=4")
vim.cmd.setlocal("suffixesadd=.sql")
vim.cmd.setlocal("tabstop=4")
-- }}}
-- {{{ commands
local range_cmd = function(opts) return "keeppatterns " .. opts.line1 .. ","  .. opts.line2 end
vim.api.nvim_create_user_command("SqlAssignColumnsToVariables",
  function(opts)
    vim.cmd((range_cmd(opts) .. "s/\\(\\w\\{-}\\.\\)\\(\\S\\+\\)$/@\\2 = &/e"))
  end,
  {desc = "Assign columns (in a SELECT statement) to variables",
    range = true,
  })

vim.api.nvim_create_user_command("SqlWhereMatchColumnsToVariables",
  function(opts)
    print(opts.line1 .. " - " .. opts.line2)
    vim.cmd((range_cmd(opts) .. "v/=/s/\\(\\w\\{-}\\.\\)\\(\\S\\+\\)$/& = @\\2/e"))
  end,
  {desc = "Match columns (in a WHERE clause) to variables",
    range = true,
  })

vim.api.nvim_create_user_command("SqlVarsToInParams",
  function(opts)
    vim.cmd((range_cmd(opts) .. "s/@/@in_/ge"))
  end,
  {desc = "Convert variables to @in_ parameters",
    range = true,
  })

vim.api.nvim_create_user_command("SqlVarsToOutParams",
  function(opts)
    vim.cmd((range_cmd(opts) .. "s/@\\S\\+/@out_& = &/ge"))
  end,
  {desc = "Assign variables to @out_ parameters",
    range = true,
  })

vim.api.nvim_create_user_command("SqlSelectAliases",
  function(opts)
    -- automatically give [aliases] to all highlighted columns
    -- SELECT                     -> SELECT
    --    @pick_id                ->    [@pick_id]          = @pick_id
    --   ,@pick_qty_in_tote       ->   ,[@pick_qty_in_tote] = @pick_qty_in_tote
    vim.cmd((range_cmd(opts) .. "s/\\s*,\\?\\zs\\(\\w\\+\\.\\)\\?\\(@\\?\\w\\+\\)/[\\2] = \\1\\2/e"))
  end,
  {desc = "Generate colums aliases (in a SELECT statement)",
    range = true,
  })

vim.api.nvim_create_user_command("SqlFixCommas",
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
  {desc = "Add commas to the beginning of each line of a list of columns in a SELECT statement",
    range = true,
  })

local rename_var = function(old, new)
  -- rename a sql variable without moving the cursor
  local cursor = vim.fn.getpos(".")
  vim.cmd("%s/@\\zs" .. old .. "\\ze\\>/" .. new .. "/g")
  vim.fn.setpos(".", cursor)
end

vim.api.nvim_create_user_command("SqlRenameVariable",
  function(opts)
    local old = nil
    local new = nil
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
  { desc = "Rename a sql variable in the current buffer",
    nargs = "*",
  })

_G.sql_snake_case_cword = function()
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
end
-- }}}
-- {{{ mappings
local mapopts = function(desc, opts) -- {{{ shorthand for adding the description
  local _t = {buffer = true, noremap = true, desc = desc}
  if opts then
    for k,v in pairs(opts) do
      _t[k] = v
    end
  end
  return _t
end -- }}}
-- {{{ INSERT
vim.keymap.set("i", "A<tab>", "AND<space>", mapopts("expand: AND"))
vim.keymap.set("i", "B<tab>", "BEGIN<cr>END<esc>O", mapopts("expand: BEGIN...END"))
vim.keymap.set("i", "BC<tab>", "<esc>!!cat ~/templates/trycatch_template.sql<cr>V`]=o", mapopts("expand: TRY...CATCH"))
vim.keymap.set("i", "BT<tab>", "BEGIN TRAN<cr><cr><cr>WHILE @@TRANCOUNT > 0 ROLLBACK TRAN<esc><<kO", mapopts("expand: BEGIN TRAN...END TRAN"))
vim.keymap.set("i", "C<tab>", "CASE<space>WHEN<esc>o<tab>END<esc>kA<space>", mapopts("expand: CASE WHEN...END"))
vim.keymap.set("i", "CR<tab>", "CONVERT()<left>", mapopts("expand: CONVERT"))
vim.keymap.set("i", "D<tab>", "DECLARE<cr><tab>", mapopts("expand: DECLARE"))
vim.keymap.set("i", "E<tab>", "EXISTS<space>(<cr><tab>SELECT<space>1<cr>FROM t_<cr>)<esc>kA", mapopts("expand: EXISTS (SELECT...FROM)"))
vim.keymap.set("i", "F<tab>", "FROM t_", mapopts("expand: FROM t_"))
-- automatically add a group-by clause that uses all non-aggregate fields from
-- the select statement
-- imap     <buffer> G>  GROUP BY<esc>yis'.p:keepp .,/\(\n\s*\(having\<bar>order by\)\<bar>\n\n\<bar>\%$\)/g/[()]/d<cr>
vim.keymap.set("i", "H<tab>", "HAVING<tab>", mapopts("expand: HAVING"))
vim.keymap.set("i", "I<tab>", "INSERT<space>INTO", mapopts("expand: INSERT INTO"))
vim.keymap.set("i", "L<tab>", "LEFT<space>OUTER<space>JOIN<space>t_<cr>ON<tab><esc>>>kA", mapopts("expand: LEFT OUTER JOIN t_ ON"))
vim.keymap.set("i", "N<tab>", "INNER<space>JOIN<space>t_<cr>ON<tab><esc>>>kA", mapopts("expand: INNER JOIN t_ ON"))
vim.keymap.set("i", "NV", "NVARCHAR()<left>", mapopts("expand: NVARCHAR()"))
vim.keymap.set("i", "O<tab>", "ORDER<space>BY<cr><tab>", mapopts("expand: ORDER BY"))
vim.keymap.set("i", "P<tab>", "PARTITION<space>BY<space>", mapopts("expand: PARTITION BY"))
vim.keymap.set("i", "SS<tab>", "SELECT 1", mapopts("expand: SELECT 1"))
vim.keymap.set("i", "ST<tab>", "SELECT TOP 1<cr><tab>", mapopts("expand: SELECT TOP 1"))
vim.keymap.set("i", "S<tab>", "SELECT<cr><tab>", mapopts("expand: SELECT"))
vim.keymap.set("i", "U<tab>", "UPDATE<space><cr>SET<tab><esc>kA", mapopts("expand: UPDATE"))
vim.keymap.set("i", "V<tab>", "OVER<space>()<left>", mapopts("expand: OVER ()"))
vim.keymap.set("i", "W<tab>", "WHERE<space>", mapopts("expand: WHERE"))
vim.keymap.set("i", "WN", "WITH<space>(NOLOCK)", mapopts("expand: WITH (NOLOCK)"))
vim.keymap.set("i", "X<tab>", "ISNULL(,<space>'')<c-o>F,", mapopts("expand: ISNULL(, '')"))
-- }}}
-- {{{ NORMAL
-- vim.keymap.set("n", "", "", mapopts(""))
vim.keymap.set("n", "<localleader>so", "<cmd>!sql mappredicate sio<cr>", -- {{{ swap operands
  mapopts("swap operands of the expression on the current line", {silent = true})) -- }}}
-- {{{ Yank commands: <localleader>y
-- TODO: rewrite these with treesitter
vim.keymap.set("n", "<localleader>yt", function()
    vim.cmd("keeppatterns 0/BEGIN TRY/+1,0/END TRY/-1y\"")
    print("Yanked: main TRY-Block contents")
  end,
  mapopts("yank contents of first TRY block", {silent = true}))
vim.keymap.set("n", "<localleader>yp", function()
    vim.cmd("keeppatterns 0/CREATE PROCEDURE/+1,/^\\s*AS\\s*$/-1y\"")
    print("Yanked: Sproc Params")
  end,
  mapopts("yank sproc parameters", {silent = true}))
vim.keymap.set("n", "<localleader>ys", function()
    vim.cmd("let @\"=system(\"sql ss '\"..expand('%:p')..\"'\")")
    print("Yanked: Sproc Signature")
  end,
  mapopts("yank sproc signature", {silent = true}))
vim.keymap.set("n", "<localleader>ya", function()
    vim.cmd("let @\"=system(\"sql ss -a '\"..expand('%:p')..\"'\")")
    print("Yanked: Sproc Architect DBAction")
  end,
  mapopts("yank Architect DBAction sproc signature", {silent = true}))
vim.keymap.set("n", "<localleader>yw", function()
    vim.cmd("let @\"=system(\"sql ss -w '\"..expand('%:p')..\"'\")")
    print("Yanked: Sproc Webwise Execute")
  end,
  mapopts("yank sproc Webwise execute signature", {silent = true}))
vim.keymap.set("n", "<localleader>yW", function()
    vim.cmd("let @\"=system(\"sql ss -W '\"..expand('%:p')..\"'\")")
    print("Yanked: Sproc Workflow Parameter Mapping")
  end,
  mapopts("yank sproc Workflow Parameter Mapping", {silent = true}))
-- }}}
vim.keymap.set("n", "<localleader>et", "<cmd>.!prodb expand table<cr>", -- {{{ expand temp-table/table-variable from shorthand
-- table definitions can take the form of
-- @table_var_name(field1, field2)
-- #temp_table_name(field1, field2)
-- or
-- @table_var_name:field1, field2
-- #temp_table_name:field1, field2
  mapopts("expand: @table_var_name:field1, field2")) -- }}}
-- {{{ tSQLt - run tests and test-suites
-- run test
vim.keymap.set("n", "<localleader>tt", function()
  local testsuite = vim.fn.expand("%:p:h:t")
  local testname  = vim.fn.expand("%:p:t:r")
  vim.cmd("DB EXEC tSQLt.Run '" .. testsuite .. ".[" .. testname .. "]'")
end, mapopts("run current test", {silent = true}))
-- run testsuite
vim.keymap.set("n", "<localleader>tT", function()
  local testsuite = vim.fn.expand("%:p:h:t")
  vim.cmd("DB EXEC tSQLt.Run '" .. testsuite .. "'")
end, mapopts("tSQLt run test suite tSQLt run current file", {silent = true}))
-- }}}
vim.keymap.set("n", "<localleader>rv", "<cmd>SqlRenameVariable<cr>", mapopts("rename variable: @old to @new"))
vim.keymap.set("n", "<localleader>cs", _G.sql_snake_case_cword, mapopts("convert variable to snake_case"))
-- }}}
-- }}}
-- {{{ VISUAL
-- vim.keymap.set("v", "", "", mapopts(""))
vim.keymap.set("v", "<localleader>U", "!sql uppercase<cr>", mapopts("uppercase SQL keywords", {silent = true}))
vim.keymap.set("v", "<localleader>=", "!prodb expand statement<cr>", mapopts("format/expand the selected statement/shorthand"))
vim.keymap.set("v", "<localleader>sa", ":SqlSelectAliases<cr>", mapopts("Generate colums aliases (in a SELECT statement)"))
vim.keymap.set("v", "<localleader>fc", ":SqlFixCommas<cr>", mapopts("format commas in SQL list", {silent = true}))
vim.keymap.set("v", "<localleader>sv", ":SqlAssignColumnsToVariables<cr>", mapopts("Assign columns (in a SELECT statement) to variables"))
vim.keymap.set("v", "<localleader>wv", ":SqlWhereMatchColumnsToVariables<cr>", mapopts("Match columns (in a WHERE clause) to variables"))
vim.keymap.set("v", "<localleader>vi", ":SqlVarsToInParams<cr>", mapopts("Convert variables to @in_ parameters"))
vim.keymap.set("v", "<localleader>vo", ":SqlVarsToInParams<cr>", mapopts("Assign variables to @out parameters"))
-- }}}
-- }}}
