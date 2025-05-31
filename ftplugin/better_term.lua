local function get_term_index(buf)
  buf = buf or 0
  local name = vim.api.nvim_buf_get_name(buf)
  local index = name:match('Term_(%d+)')
  if not index then return end
  return index
end

local function index_to_name(index) return 'Term_' .. index end

-- return a list of better_term filetype buffers
---@return { buf: integer, index: integer }[]
local function get_terms()
  local bufs = {} ---@type { buf: integer, index: integer }
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local filetype = vim.api.nvim_get_option_value('filetype', { buf = buf })
    if filetype == 'better_term' then
      table.insert(bufs, { buf = buf, index = get_term_index(buf) })
    end
  end
  -- sort by index
  table.sort(bufs, function(a, b) return a.index < b.index end)
  return bufs
end

local function term_prev()
  local current = get_term_index()
  if not current then return end

  local terms = get_terms()
  if #terms == 1 then return end

  -- find the first buffer with an index less than the current
  local target = terms[#terms] -- wrap around if none found
  for i = #terms, 1, -1 do
    local term = terms[i]
    if term.index < current then
      target = term
      break
    end
  end
  require('betterTerm').open(index_to_name(target.index))
end

local function term_next()
  local current = get_term_index()
  if not current then return end

  local terms = get_terms()
  if #terms == 1 then return end

  -- find the first buffer with an index greater than the current
  local target = terms[1] -- wrap around if none found
  for _, term in ipairs(terms) do
    if term.index > current then
      target = term
      break
    end
  end
  require('betterTerm').open(index_to_name(target.index))
end

vim.api.nvim_buf_set_keymap(0, 'n', '<', '', {
  desc = 'Previous Terminal',
  callback = term_prev
})

vim.api.nvim_buf_set_keymap(0, 'n', '>', '', {
  desc = 'Previous Terminal',
  callback = term_next
})
