local api = vim.api
local fun = vim.fn
local not_empty = require('util').not_empty

---create a new augroup for the given autocmds
---@param name string
---@param commands [string[], vim.api.keyset.create_autocmd][]
local function augroup(name, commands)
  assert(not_empty(name),     'name required')
  assert(not_empty(commands), 'commands required')

  local id = api.nvim_create_augroup(name, { clear = true })
  for _,cmd in ipairs(commands) do
    local events, opts = cmd[1], cmd[2]
    opts.group = id
    api.nvim_create_autocmd(events, opts)
  end
end

augroup('JUMP_LAST_EDIT', {
  { {'BufReadPost'}, { pattern = '*',
    desc = 'return to last edit position when opening files',
    command = "silent! call setpos('.', getpos(\"'\\\"\"))",
  }}
})

augroup('COLOR_COLUMN', {
  { {'BufReadPost', 'BufNew'}, { pattern = '*', command = 'set colorcolumn=80' } },
})

augroup('TOGGLE_HLSEARCH', {
  { {'InsertEnter'}, { pattern = '*', command = 'set nohlsearch' } },
  { {'CmdlineEnter'}, { pattern = '?', command = 'set hlsearch' } },
  { {'CmdlineEnter'}, { pattern = '/', command = 'set hlsearch' } },
})

augroup('CURSOR_LINE', {
  { {'WinEnter'}, { pattern = '*', command = 'set cursorline' } },
  { {'WinLeave'}, { pattern = '*', command = 'set nocursorline nocursorcolumn' } },
})

augroup('TOGGLE_LIST_CHARS', {
  { {'InsertEnter'}, { pattern = '*', command = 'set nolist' } },
  { {'InsertLeave'}, { pattern = '*', command = 'set list' } },
})

augroup('TERMINAL_ENTER', {
  { {'TermOpen'}, { pattern = '*', command = 'setlocal nonumber norelativenumber' } },
  { {'TermOpen'}, { pattern = '*', command = 'startinsert' } },
})

return {
  augroup = augroup,
}