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

local function toggle_init()
  local pref = function(s)
    return ('<leader>o%s'):format(assert(s, 'argument required'))
  end

  local conf = {
    background     = Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }),
    conceal_cursor = Snacks.toggle.option("conceal_cursor", { name = "ConcealCursor" }),
    conceallevel   = Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }),
    cursorcolumn   = Snacks.toggle.option("cursorcolumn", { name = "Cursorcolumn" }),
    cursorline     = Snacks.toggle.option("cursorline", { name = "Cursorline" }),
    diagnostics    = Snacks.toggle.diagnostics(),
    ignorecase     = Snacks.toggle.option("ignorecase", { name = "Ignorecase" }),
    indent         = Snacks.toggle.indent(),
    inlay_hints    = Snacks.toggle.inlay_hints(),
    line_number    = Snacks.toggle.line_number(),
    list           = Snacks.toggle.option("list", { name = "List" }),
    relativenumber = Snacks.toggle.option("relativenumber", { name = "Relative Number" }),
    hlsearch       = Snacks.toggle.option("hlsearch", { name = "Search Highlight" }),
    spell          = Snacks.toggle.option("spell", { name = "Spelling" }),
    treesitter     = Snacks.toggle.treesitter(),
    wrap           = Snacks.toggle.option("wrap", { name = "Wrap" }),
    zen            = Snacks.toggle.zen(),
    zoom           = Snacks.toggle.zoom(),
  }

  conf.third_party = {
    cloak = Snacks.toggle.new {
      name = "Cloak",
      get = function()
        local ok, cloak = pcall(require, 'cloak')
        return ok and cloak.opts.enabled or false
      end,
      set = function(state)
        local ok, cloak = pcall(require, 'cloak')
        assert(ok, 'cloak.nvim required for this functionality')
        cloak[(state and 'enable' or 'disable')]()
      end,
    },
    csvview = Snacks.toggle.new {
      name = 'CSV View',
      get  = function()
        local ok, csvview = pcall(require, 'csvview')
        return ok and csvview.is_enabled(0) or false
      end,
      set  = function(state)
        local ok, csvview = pcall(require, 'csvview')
        assert(ok, 'csvview.nvim required for this functionality')
        csvview[(state and 'enable' or 'disable')]()
      end
    },
    codeium = Snacks.toggle.new {
      name = 'Codeium Suggestions',
      get  = function()
        return vim.b.codeium_enabled or false
      end,
      set  = function(state)
        local ok, _ = pcall(require, 'codeium')
        assert(ok, 'windsurf.nvim required for this functionality')
        vim.b.codeium_enabled = state
      end
    },
    git_signcolumn = Snacks.toggle.new {
      name = 'Git SignColumn',
      get  = function()
        local ok, gitsigns = pcall(require, 'gitsigns.config')
        return ok and gitsigns.config.signcolumn or false
      end,
      set  = function(state)
        local ok, gitsigns = pcall(require, 'gitsigns')
        assert(ok, 'gitsigns.nvim required for this functionality')
        gitsigns.toggle_signs(state)
      end
    },
    git_word_diff = Snacks.toggle.new {
      name = 'Git Word Diff',
      get  = function()
        local ok, gitsigns = pcall(require, 'gitsigns.config')
        return ok and gitsigns.config.word_diff or false
      end,
      set  = function(state)
        local ok, gitsigns = pcall(require, 'gitsigns')
        assert(ok, 'gitsigns.nvim required for this functionality')
        gitsigns.toggle_word_diff(state)
      end,
    },
    git_current_line_blame = Snacks.toggle.new {
      name = 'Git Blame (current line)',
      get  = function()
        local ok, gitsigns = pcall(require, 'gitsigns.config')
        return ok and gitsigns.config.current_line_blame or false
      end,
      set  = function(state)
        local ok, gitsigns = pcall(require, 'gitsigns')
        assert(ok, 'gitsigns.nvim required for this functionality')
        gitsigns.toggle_current_line_blame(state)
      end
    },
  }

  for k, v in pairs {
    [pref 'b']  = conf.background,
    [pref 'C']  = conf.third_party.cloak,
    [pref 'cC'] = conf.conceal_cursor,
    [pref 'cc'] = conf.cursorcolumn,
    [pref 'cL'] = conf.conceallevel,
    [pref 'cl'] = conf.cursorline,
    [pref 'cv'] = conf.third_party.csvview,
    [pref 'cs'] = conf.third_party.codeium,
    [pref 'd']  = conf.diagnostics,
    [pref 'gb'] = conf.third_party.git_current_line_blame,
    [pref 'gs'] = conf.third_party.git_signcolumn,
    [pref 'gw'] = conf.third_party.git_word_diff,
    [pref 'h']  = conf.hlsearch,
    [pref 'ic'] = conf.ignorecase,
    [pref 'ih'] = conf.inlay_hints,
    [pref 'in'] = conf.indent,
    [pref 'l']  = conf.list,
    [pref 'n']  = conf.line_number,
    [pref 'r']  = conf.relativenumber,
    [pref 's']  = conf.spell,
    [pref 't']  = conf.treesitter,
    [pref 'w']  = conf.wrap,
    [pref 'z']  = conf.zen,
    [pref 'Z']  = conf.zoom,
  } do assert(v, 'invalid toggle config for map '..k):map(k) end
end

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
    zen = {
      enabled = true,
      win = {
        backdrop = { transparent = false },
        keys = {
          { '<leader>z', function() Snacks.toggle.dim():toggle() end, mode = 'n' },
        },
      },
      on_open = function(win)
      end,
      on_close = function(win)
        vim.api.nvim_buf_set_keymap(win.buf, 'n', '<leader>z', '', {
          callback = function() Snacks.toggle.zen():toggle() end,
        })
      end,
    },
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
    notifier = { enabled = true, level = vim.log.levels.INFO },
  },
  keys = make_mappings({
    { 'Zen Mode', '<leader>z', run 'Snacks.zen()' },
    { 'Zoom',     '<leader>Z', run 'Snacks.zen.zoom()' },
    { 'Notification History', '<leader>N', run 'Snacks.notifier.show_history()' },
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

        toggle_init()
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
