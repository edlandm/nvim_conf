local setopts = require 'config.settings'.setopts

setopts('wo', {
  { 'conceallevel',  2 },
  { 'concealcursor', 'nc' },
  { 'wrap',          false },
})

setopts('bo', {
  { 'shiftwidth', 2 },
  { 'tabstop',    2 },
})

---create a function that creates a popup window in which to display lines
---if lines are given, create the window immediately instead of returning
---a function
---@param title string? title of the popup (defaults to module name)
---@param opts table window options to pass to the popup window
---@param lines string[]? if present, create the window immediately and populate it with these lines
---@return fun(lines: string[])?
local function popup_window(title, opts, lines)
  local winfn = function (_lines)
    assert(_lines and #_lines > 0, "lines required")

    local longest_line = 1
    for _, line in  ipairs(_lines) do
      if #line > longest_line then
        longest_line = #line
      end
    end

    local style = 'split'
    local relative = 'win'
    local position = 'right'

    local width = nil
    local height = nil
    if #_lines <= 10 and longest_line <= 40 then
      -- small enough payloads can just be a floating window
      relative = 'cursor'
      position = 'float'
      style = 'minimal'
      height = #_lines
      width = longest_line
    elseif longest_line > 70 then
      -- force horizontal split if the content is too wide
      position = 'bottom'
      local max_height = vim.api.nvim_win_get_height(0) / 2
      if #_lines >= max_height then
        height = max_height
      else
        height = #lines
      end
    else
      -- vertical split to the right if only one window, else horizontal spit
      local winlayout = vim.fn.winlayout()
      if winlayout[1] == 'leaf' then
        position = 'right'
      else
        position = 'bottom'
      end
    end

    local winopts = {
      style = style,
      relative = relative,
      height = height,
      width = width,
      position = position,
      row = 1,
      col = 0,
      enter = true,
      ft = 'scratch',
      fixbuf = true,
      text = _lines,
      keys = {
        q = "close",
      },
    }

    -- use splitkeep='screen' just for this split so that the top window (if
    -- horizontal split) doesn't scroll; it looks weird/disorienting
    local _splitkeep = vim.o.splitkeep
    vim.o.splitkeep = 'screen'
    require('snacks').win(vim.tbl_deep_extend('keep', opts, winopts))
    vim.o.splitkeep = _splitkeep
  end

  if lines then
    winfn(lines)
    return
  end
  return winfn
end

---if the cursor is within a @code block, determine the language and then pass
---the lines to the configured code-runner for that language.
---Currently Configured:
--- - lua
local function run_codeblock()
  local code_block = require('util').find_node_ancestor(
    { 'ranged_verbatim_tag' },
    assert(vim.treesitter.get_node(), 'Unable to get cursor node.'))

  local notify = vim.schedule_wrap(vim.api.nvim_echo)
  if not code_block then
    notify('Not in Code-block', vim.log.levels.INFO, {})
    return
  end

  local lang_query = vim.treesitter.query.parse('norg', [[
    (ranged_verbatim_tag (tag_parameters (tag_param) @lang))
  ]])
  assert(lang_query, 'Invalid Treesitter Query')

  local lang
  for id, node, _, _ in lang_query:iter_captures(code_block, 0) do
    local name = lang_query.captures[id]
    if name == 'lang' then
      local srow, scol, erow, ecol = node:range()
      local node_text = vim.api.nvim_buf_get_text(0, srow, scol, erow, ecol, {})[1]
      lang = node_text
      break
    end
  end
  assert(lang, 'Unable to determine language of code-block')

  -- zero-based line-numbers
  local srow, scol, erow, ecol = code_block:range()
  assert(erow, 'unable to get end range of codeblock')

  local function getlines()
    return vim.tbl_map(
      vim.trim,
      vim.api.nvim_buf_get_lines(0, srow+1, erow, true))
  end

  local bufid = vim.api.nvim_win_get_buf(0)
  local function flash()
    local ns = vim.api.nvim_create_namespace('NEORG_RUN_CODEBLOCK')
    vim.hl.range(bufid, ns, 'Visual', { srow+1, scol }, { erow, 0 })

    vim.defer_fn(function()
      vim.api.nvim_buf_clear_namespace(bufid, ns, 0, -1)
    end, 250)
  end

  if lang == 'lua' then
    -- one-based, end-inclusive
    vim.cmd({ cmd = 'lua', range = { srow+2, erow } })
    flash()
  elseif lang == 'env' then
    -- zero-based, end-exclusive
    local lines = getlines()
    for _, line in ipairs(lines) do
      local key, val = string.match(line, '([^#%s]%S-)=(%S.-)$')
      if key then
        if val:sub(1, 1) == "'" and val:sub(-1, -1) == "'" then
          val = val:sub(2, -2)
        end
        vim.fn.setenv(key, val)
      else
        -- optionally allow a line to contain a path to an env file
        local path = vim.fn.expand(line)
        local success, _, err = vim.uv.fs_stat(path)
        assert(success, ('file not found: %s'):format(err))
        local dict = require('util').read_key_val_file(path, '=')
        for k,v in pairs(dict) do
          vim.fn.setenv(k,v)
        end
      end
    end
    notify('Set Environment Variables', vim.log.levels.DEBUG, {})
    flash()
  elseif lang == 'bash' then
    vim.fn.system('bash', getlines())
    flash()
  elseif lang == 'sql' then
    -- zero-based, end-exclusive
    local lines = getlines()
    assert(#lines > 0, 'No lines in Code-block')

    local tempname = vim.fn.tempname()
    local tempfile = assert(
      io.open(tempname, 'w'),
      'unable to open temp-file for writing: '..tempname)

    tempfile:write('SET NOCOUNT ON;\n')
    tempfile:write(table.concat(lines, '\n'))
    tempfile:close()

    vim.system({ 'sqlcmd', '-i', tempname, '-r', '1' }, { text = true }, function (obj)
      -- clean up
      local rm_success, err = os.remove(tempname)
      assert(rm_success, err)

      if obj.code > 0 then
        local msg
        if obj.stderr ~= '' then
          msg = ('sqlcmd :: %s'):format(obj.stderr)
        elseif obj.stdout ~= '' then
          msg = ('sqlcmd :: %s'):format(obj.stdout)
        else
          msg = 'sqlcmd exited with a non-zero exit-code'
        end
        notify(msg, vim.log.levels.ERROR, {})
        return
      end

      local out_lines = vim.split(obj.stdout, '\n')

      -- trim blank lines from beginning and end
      while #out_lines > 0 and out_lines[1]:match('^%s*$') do
        table.remove(out_lines, 1)
      end

      while #out_lines > 0 and out_lines[#out_lines]:match('^%s*$') do
        table.remove(out_lines, #out_lines)
      end

      vim.schedule(flash)

      if #out_lines == 0 then
        notify('SQL executed with no results', vim.log.levels.INFO, {})
        return
      end

      vim.schedule(function()
        popup_window('SQL RESULTS', { bo = { ft = 'sqlresults' } }, out_lines)
      end)
    end)
  else
    notify('Code-block runner not configured for language: '..lang,
      vim.log.levels.ERROR, {})
    return
  end
end

local mappings = require 'config.mappings'
local ll = mappings.lleader

mappings.map{
  { mode = 'n', buffer = true,
    { "neorg: follow link",                     "<CR>",       "<Plug>(neorg.esupports.hop.hop-link)",             },
    { "neorg: open link in vsplit",             "<c-w><c-v>", "<Plug>(neorg.esupports.hop.hop-link.vsplit)",      },
    { "neorg: edit code-block in new buffer",   ll("e"),      "<Plug>(neorg.looking-glass.magnify-code-block)",   },
    { "neorg: run code-block",                  ll("r"),      run_codeblock,                                      },
    { "neorg: demote item (nested)",            "<<",         "<Plug>(neorg.promo.demote.nested)",                },
    { "neorg: demote item",                     "< ",         "<Plug>(neorg.promo.demote)",                       },
    { "neorg: promote item (nested)",           ">>",         "<Plug>(neorg.promo.promote.nested)",               },
    { "neorg: promote item",                    "> ",         "<Plug>(neorg.promo.promote)",                      },
    { "neorg: invert all items in list",        ll("li"),     "<Plug>(neorg.pivot.list.invert)",                  },
    { "neorg: toggle list ordered<->unordered", ll("lt"),     "<Plug>(neorg.pivot.list.toggle)",                  },
    { "neorg: set task to ambiguous",           ll("ta"),     "<Plug>(neorg.qol.todo-items.todo.task-ambiguous)", },
    { "neorg: set task to cancelled",           ll("tc"),     "<Plug>(neorg.qol.todo-items.todo.task-cancelled)", },
    { "neorg: set task to done",                ll("td"),     "<Plug>(neorg.qol.todo-items.todo.task-done)",      },
    { "neorg: set task to hold",                ll("th"),     "<Plug>(neorg.qol.todo-items.todo.task-on-hold)",   },
    { "neorg: set task to important",           ll("ti"),     "<Plug>(neorg.qol.todo-items.todo.task-important)", },
    { "neorg: set task to pending",             ll("tp"),     "<Plug>(neorg.qol.todo-items.todo.task-pending)",   },
    { "neorg: set task to recurring",           ll("tr"),     "<Plug>(neorg.qol.todo-items.todo.task-recurring)", },
    { "neorg: set task to undone",              ll("tu"),     "<Plug>(neorg.qol.todo-items.todo.task-undone)",    },
  },
  { mode = 'x', buffer = true,
    { "neorg: demote range",  "<", "<Plug>(neorg.promo.demote.range)",  },
    { "neorg: promote range", ">", "<Plug>(neorg.promo.promote.range)", },
  },
  { mode = 'i', buffer = true,
    { "neorg: demote item (nested)",      "<c-d>", "<Plug>(neorg.promo.demote.nested)",  },
    { "neorg: promote item (nested)",     "<c-t>", "<Plug>(neorg.promo.promote.nested)", },
    { "neorg: create a noew list/header", ";n",    "<Plug>(neorg.itero.next-iteration)", },
  },
}
