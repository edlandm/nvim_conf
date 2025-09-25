local pkg_name = 'markdown'
package.loaded[pkg_name] = { name = pkg_name }
local M = package.loaded[pkg_name]

---attempt to find a matching ancestor of a given node
---@param types string[]
---@param node TSNode
---@return TSNode?
local function find_node_ancestor(types, node)
  assert(types, 'find_node_ancestor :: `types required`')

  if not node then
    return nil
  end

  if vim.tbl_contains(types, node:type()) then
    return node
  end

  local parent = node:parent()
  if not parent then
    return nil
  end

  return find_node_ancestor(types, parent)
end

---add a new list item to the current list (or start a list)
---setting opts.append_at to 'list' appends to the end of list, versus after the
---current item
---@param opts { append_at: 'item' | 'list', type: 'item' | 'task' }
function M.add_list_item(opts)
  opts = vim.tbl_deep_extend('keep', opts or {}, { append_at = 'item' })
  local li = opts.type == 'task' and '- [ ] ' or '- '
  local cur_pos = vim.api.nvim_win_get_cursor(0)
  -- determine if cursor is inside a list, if add a new list item after the
  -- current one, else prevent the current line with a list item marker
  local cur_node = assert(vim.treesitter.get_node(), 'Unable to get cursor node.')
  local list_item = find_node_ancestor({ 'list_item' }, cur_node)

  if not list_item then
    -- turn current paragraph or current line into list item
    local paragraph = find_node_ancestor({ 'paragraph' }, cur_node)

    if paragraph then
      local p_srow, p_scol, p_erow, p_ecol = paragraph:range()
      local line = vim.api.nvim_buf_get_lines(0, p_srow, p_srow+1, true)[1]
      line = li .. line
      vim.api.nvim_buf_set_lines(0, p_srow, p_srow+1, true, { line })
      vim.api.nvim_win_set_cursor(0, { p_erow, p_erow == p_srow and #line or p_ecol })
      return
    else
      local line = vim.api.nvim_get_current_line()
      line = li .. line
      vim.api.nvim_buf_set_lines(0, cur_pos[1]-1, cur_pos[1], true, { line })
      vim.api.nvim_win_set_cursor(0, { cur_pos[1], #line })
    end

    return
  end

  if opts.append_at == 'list' then
    local list = find_node_ancestor({ 'list' }, list_item)
    assert(list, 'impossible: list_item found without list')
    local l_srow, l_scol, l_erow, l_ecol = list:range()
    local lines = vim.api.nvim_buf_get_lines(0, l_erow-2, l_erow, true)
    local l_eline = lines[2]
    if l_eline:match('^%s*$') and lines[1]:match('%-') then
      l_erow = l_erow - 1
    end

    local l_sline = vim.api.nvim_buf_get_lines(0, l_srow, l_srow+1, true)[1]
    l_scol = (l_sline:find('%-'))-1 or l_scol
    local line = string.rep(' ', l_scol) .. li

    vim.api.nvim_buf_set_lines(0, l_erow, l_erow, true, { line })
    vim.api.nvim_win_set_cursor(0, { l_erow+1, #line })
    return
  end

  local i_srow, i_scol, i_erow, i_ecol = list_item:range()
  local lines = vim.api.nvim_buf_get_lines(0, i_erow-2, i_erow, true)
  local i_eline = lines[2]
  if i_eline:match('^%s*$') and lines[1]:match('%-') then
    i_erow = i_erow - 1
  end

  local i_sline = vim.api.nvim_buf_get_lines(0, i_srow, i_srow+1, true)[1]
  i_scol = (i_sline:find('%-'))-1 or i_scol
  local line = string.rep(' ', i_scol) .. li
  vim.api.nvim_buf_set_lines(0, i_erow, i_erow, true, { line })
  vim.api.nvim_win_set_cursor(0, { i_erow+1, #line })
end

---add a new list item to the current list (or start a list)
---setting opts.append_at to 'list' appends to the end of list, versus after the
---current item
---if the current list item is not a task, it is converted to one
---@param opts { append_at: 'item' | 'list' }
function M.add_task(opts)
  local cur_node = assert(vim.treesitter.get_node(), 'Unable to get cursor node.')
  local list_item = find_node_ancestor({ 'list_item' }, cur_node)
  if opts.append_at == 'item' and list_item then
    local i_srow, i_scol, i_erow, i_ecol = list_item:range()
    local i_sline = vim.api.nvim_buf_get_lines(0, i_srow, i_srow+1, true)[1]
    local is_task = i_sline:match('- %b[]')
    -- if our current item is already a task, then we'll add a new one below
    -- the current one, else convert the current item to a task
    if not is_task then
      local line = i_sline:gsub('^(%s*%- )', '%1[ ] ')
      vim.api.nvim_buf_set_lines(0, i_srow, i_srow+1, true, { line })
      vim.api.nvim_win_set_cursor(0, { i_erow, #line })
      return
    end
  end

  M.add_list_item(vim.tbl_deep_extend('keep', { type = 'task' }, opts))
end

local default_opts = {}

function M.setup(opts)
  M.opts = vim.tbl_deep_extend('keep', opts or {}, default_opts)
  return M
end

return M
