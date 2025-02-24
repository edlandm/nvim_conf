---shorthand for creating keymaps in a format that I prefer
---@param maps [string,string,string|function][]
local function make_mappings(maps)
  local mappings = {}
  for _, map in ipairs(maps) do
    local desc, lhs, rhs, mode = unpack(map)
    table.insert(mappings, { lhs, rhs, desc = desc, mode = mode or 'n' })
  end
  return mappings
end

local function run(c) return ('<cmd>lua %s<cr>'):format(c) end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  dependencies = {
    'edlandm/holster.nvim'
  },
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    zen     = { enabled = true, win = { backdrop = { transparent = false } } },
    dim     = { enabled = true },
    debug   = { enabled = true },
    scroll  = { enabled = true },
    win     = { enabled = true },
    image   = { enabled = true },
    input   = { enabled = true, win = { style = 'input', title_pos = 'left' } },
    indent = {
      enabled = true,
      -- |¦‖｜￤∥ǀ∣│❘┃
      char = '┃',
      hl = {
        "SnacksIndent1",
        "SnacksIndent2",
        "SnacksIndent3",
        "SnacksIndent4",
        "SnacksIndent5",
        "SnacksIndent6",
        "SnacksIndent7",
        "SnacksIndent8",
      },
      only_scope = false, -- only show indent guides of the scope
      scope = {
        enabled = true, -- enable highlighting the current scope
        priority = 200,
        char = "┃",
        underline = false, -- underline the start of the scope
        only_current = false, -- only show scope in the current window
        hl = {
          "SnacksIndent1",
          "SnacksIndent2",
          "SnacksIndent3",
          "SnacksIndent4",
          "SnacksIndent5",
          "SnacksIndent6",
          "SnacksIndent7",
          "SnacksIndent8",
        },
      },
      animate = {
        enabled = vim.fn.has("nvim-0.10") == 1,
        style = "out",
        easing = "linear",
        duration = {
          step = 40, -- ms per step
          total = 300, -- maximum duration
        },
      },
    },
  },
  keys = make_mappings({
    { 'Zen Mode', '<leader>z', run 'Snacks.zen()' },
    { 'Zoom',     '<leader>Z', run 'Snacks.zen.zoom()' },
  }),
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        _G.Snacks = require('snacks')
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command
      end,
    })

    vim.api.nvim_create_user_command('News', function()
      local file
      for _, f in ipairs(vim.api.nvim_get_runtime_file("doc/news.txt", true)) do
        -- I happen to have multiple matches for doc/news.txt in my runtime
        -- files, so I need to find the actual neovim one
        -- (others are for plugins)
        if f:match('nvim/runtime/doc/news.txt') then
          file = f
          break
        end
      end

      if not file then
        print('News file not found')
        return
      end

      Snacks.win({
        file = file,
        width = 0.6,
        height = 0.7,
        wo = {
          spell = false,
          wrap = false,
          signcolumn = "yes",
          statuscolumn = " ",
          conceallevel = 3,
        },
      })

    end, { desc = 'Open Neovim News in floating window' })
  end,
}
