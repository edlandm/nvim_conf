---@alias path string

---read the file at `path` and return a dictionary full of paths
---@param path path
---@return { [string]: path }
local function read_workspaces(path)
  assert(path, 'path required')
  assert(vim.fn.filereadable(path) == 1, ('file not readable: %s'):format(path))

  ---@type { [string]: path }
  local workspaces = {}
  local i = 0
  for line in io.lines(path) do
    i = i + 1
    if not (line:match('^#') or line:match('^%s*$')) then
      local s, e = line:find('%s+')
      assert(s and s > 1, ('parse error: line %d: %s\n'):format(i, line))

      local name = line:sub(1, s-1)
      local dir = line:sub(e+1)
      assert(not workspaces[name],
        ('duplicate workspace: %s on line %d'):format(name, i))

      ---@type path
      local _dir = vim.fn.expand(dir)
      assert(vim.fn.isdirectory(_dir) == 1,
        ('fs error line %d: directory not found: '):format(i, _dir))

      workspaces[name] = _dir
    end
  end

  return workspaces
end

return {
  'nvim-neorg/neorg',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'vhyrro/luarocks.nvim',
    'gregorias/coop.nvim',
  },
  opts = {
    load = {
      ['core.defaults'] = {},
      ['core.concealer'] = {},
      ['core.export'] = {},
      ['core.itero'] = {},
      ['core.dirman'] = {
        config = {
          workspaces = read_workspaces(
            ('%s/workspaces.txt'):format(vim.fn.stdpath('config'))
          ) or {},
          default_workspace = "nvim",
        },
      },
      -- ['core.completion'] = {
      --   config = {
      --     engine = "nvim-cmp",
      --   }
      -- },
      -- ['core.ui.calendar'] = {},
      ['core.keybinds'] = {
        config = {
          default_keybinds = false,
        }
      },
      ['core.journal'] = {
        config = {
          strategy = "flat",
        }
      },
      ['core.qol.todo_items'] = {
        config = {
          create_todo_items = true,
          create_todo_parents = false,
        },
      },
    }
  },
  ft = {
    'norg',
  },
  cmd = {
    'Neorg',
  },
}
