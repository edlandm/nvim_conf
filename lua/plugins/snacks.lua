local uv = vim.uv or vim.loop

local commands = {
  fd = { "--type", "d", "--color", "never", "-E", ".git" },
  find = { ".", "-type", "d", "-not", "-path", "*/.git/*" },
}

---@param opts snacks.picker.files.Config
---@param filter snacks.picker.Filter
local function get_cmd(opts, filter)
  local cmd, args ---@type string, string[]
  if vim.fn.executable("fd") == 1 then
    cmd, args = "fd", commands.fd
  elseif vim.fn.executable("fdfind") == 1 then
    cmd, args = "fdfind", commands.fd
  elseif vim.fn.executable("find") == 1 and vim.fn.has("win-32") == 0 then
    cmd, args = "find", commands.find
  else
    error("No supported finder found")
  end
  args = vim.deepcopy(args)
  local is_fd, is_fd_rg, is_find, is_rg = cmd == "fd" or cmd == "fdfind", cmd ~= "find", cmd == "find", cmd == "rg"

  -- hidden
  if opts.hidden and is_fd_rg then
    table.insert(args, "--hidden")
  elseif not opts.hidden and is_find then
    vim.list_extend(args, { "-not", "-path", "*/.*" })
  end

  -- ignored
  if opts.ignored and is_fd_rg then
    args[#args + 1] = "--no-ignore"
  end

  -- follow
  if opts.follow then
    args[#args + 1] = "-L"
  end

  -- file glob
  ---@type string?
  local pattern = filter.search
  pattern = pattern ~= "" and pattern or nil
  if pattern then
    if is_fd then
      table.insert(args, pattern)
    elseif is_rg then
      table.insert(args, "--glob")
      table.insert(args, pattern)
    elseif is_find then
      table.insert(args, "-name")
      table.insert(args, pattern)
    end
  end

  -- dirs
  if opts.dirs and #opts.dirs > 0 then
    local dirs = vim.tbl_map(vim.fs.normalize, opts.dirs) ---@type string[]
    if is_fd and not pattern then
      args[#args + 1] = "."
    end
    if is_find then
      table.remove(args, 1)
      for _, d in pairs(dirs) do
        table.insert(args, 1, d)
      end
    else
      vim.list_extend(args, dirs)
    end
  end

  return cmd, args
end

local custom_pickers = {}

function custom_pickers.directories()
  local picker = require('snacks.picker')
  picker.pick {
    ---@param opts snacks.picker.files.Config
    ---@param filter snacks.picker.Filter
    source = 'Directories',
    finder = function(opts, filter)
      local cwd = not (opts.dirs and #opts.dirs > 0) and vim.fs.normalize(opts and opts.cwd or uv.cwd() or ".") or nil
      local cmd, args = get_cmd(opts, filter)
      return require("snacks.picker.source.proc").proc(vim.tbl_deep_extend("force", {
        cmd = cmd,
        args = args,
        ---@param item snacks.picker.finder.Item
        transform = function(item)
          item.cwd = cwd
          item.file = item.text
        end,
      }, opts or {}))
    end,
    -- TODO: update input window title to include cwd
    actions = {
      back = {
        action = function(self, item)
          local parent_dir = (item and item.cwd or self.opts.cwd):match('^(.+)/.+$')
          if not parent_dir then
            return false
          end
          self.opts.cwd = parent_dir
          self.input:set('')
          self:find()
          return true
        end,
        desc = 'Move up/back one directory',
      },
      forward = {
        action = function(self, item)
          if not item or item.file == '/' then
            return false
          end
          self.opts.cwd = vim.fs.joinpath(item.cwd, item.file)
          self.input:set('')
          self:find()
          return true
        end,
        desc = 'Move into selected directory',
      },
      cd = {
        action = function(self, item)
          if not item or item.file == '/' then
            return false
          end
          local path = vim.fs.joinpath(item.cwd, item.file)
          self:close()
          vim.cmd('cd ' .. path)
          print("cd -> " .. item.file)
          return true
        end,
        desc = 'Move into selected directory',
      },
    },
    win = {
      input = {
        keys = {
          ['<c-left>'] = { 'back', mode = { 'i', 'n' } },
          ['<c-right>'] = { 'forward', mode = { 'i', 'n' } },
          ['<c-e>'] = { 'cd', mode = { 'i', 'n' } },
        },
      },
    },
    on_show = function(self)
      self.opts.cwd = vim.uv.cwd()
    end
  }
end

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
local function tab(s) return '<tab>'..s end
local function leader(s) return '<leader>'..s end
local function pick(s) return ('Snacks.picker.%s()'):format(s) end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    zen = { enabled = true },
    dim = { enabled = true },
    debug = { enabled = true },
    scroll = { enabled = true },
    win = { enabled = true },
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
    picker = {
      config = function(opts, defaults)
        -- TODO: I want a directory picker that can either cd/lcd to the
        -- chosen directory or open it (with oil, though that should
        -- be implicit)
        Snacks.picker.directories = custom_pickers.directories

        -- TODO: Cabinet workspace picker
        -- selecting the workspace opens it (duh)
        -- should have a keymap to edit the workspace file
      end,
    },
  },
  keys = make_mappings({
    { 'Zen Mode', '<leader>z', run 'Snacks.zen()' },
    { 'Zoom',     '<leader>Z', run 'Snacks.zen.zoom()' },
    -- picker ---------------------------------------------------------------
    { 'Pick Files',           '<c-p>',      run(pick 'files') },
    { 'Pick Directories',     tab('.'),     run(pick 'directories') },
    { 'Pick Resume',          tab('<tab>'), run(pick 'resume') },
    { 'Pick Diagnostics',     tab('d'),     run(pick 'diagnostics') },
    { 'Pick Commands',        tab('C'),     run(pick 'commands') },
    { 'Pick Command History', tab(':'),     run(pick 'command_history') },
    { 'Pick Search History',  tab('/'),     run(pick 'search_history') },
    { 'Pick Colorschemes',    tab('c'),     run(pick 'colorschemes') },
    { 'Pick Autocmds',        tab('a'),     run(pick 'autocmds') },
    { 'Pick Help',            tab('h'),     run(pick 'help') },
    { 'Pick Registers',       tab('"'),     run(pick 'registers') },
    { 'Pick Marks',           tab("'"),     run(pick 'marks') },
    { 'Pick Keymaps',         tab('k'),     run(pick 'keymaps') },
    { 'Pick H[i]lights',      tab('i'),     run(pick 'highlights') },
    { 'Pick Man Pages',       tab('m'),     run(pick 'man') },
    -- git
    { 'Pick Git Log',    tab('gl'), run(pick 'git_log') },
    { 'Pick Git Files',  tab('gf'), run(pick 'git_files') },
    { 'Pick Git Status', tab('gs'), run(pick 'git_status') },
    -- grep/search
    { 'Grep',                 '//',         run(pick 'grep') },
    { 'Grep Buffers',         leader('sb'), run(pick 'grep_buffers') },
    { 'Grep Buffer Lines ',   leader('sl'), run(pick 'lines') },
    { 'Grep <cword>',         leader('ss'), run(pick 'grep_word') },
    { 'Grep <visual>',        leader('s'),  run(pick 'grep_word'),      { 'x' } },
    { 'Search Quickfix List', leader('sc'), run(pick 'qflist') },
    -- LSP
    { 'Goto Definition',      'gd',   run(pick 'lsp_definitions') },
    { 'References',           'grr',   run(pick 'lsp_references') },
    { 'Goto Implementation',  'gi',   run(pick 'lsp_implementations') },
    { 'Goto Type Definition', 'gt',   run(pick 'lsp_definitions') },
    { 'LSP Symbols',          'gs',   run(pick 'lsp_symbols') },
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
