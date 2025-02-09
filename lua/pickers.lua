local modname = 'pickers'
package.loaded[modname] = {}
local M = package.loaded[modname]

---@class Snacks.pickers.custom
---@field directories snacks.Picker easily navigate to directories, cd to them, open a terminal there, or open in oil
---@field plugins snacks.Picker list all Lazy plugins, reload, update, open github url in browser

local uv = vim.uv or vim.loop

local directory_finder_commands = {
  fd = { "--type", "d", "--color", "never", "-E", ".git" },
  find = { ".", "-type", "d", "-not", "-path", "*/.git/*" },
}

---@param opts { hidden:boolean, ignored:boolean, follow:boolean }:snacks.picker.Config
---@param filter snacks.picker.Filter
local function get_dir_find_cmd(opts, filter)
  local cmd, args ---@type string, string[]
  if vim.fn.executable("fd") == 1 then
    cmd, args = "fd", directory_finder_commands.fd
  elseif vim.fn.executable("fdfind") == 1 then
    cmd, args = "fdfind", directory_finder_commands.fd
  elseif vim.fn.executable("find") == 1 and vim.fn.has("win-32") == 0 then
    cmd, args = "find", directory_finder_commands.find
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

  return cmd, args
end

--- easily navigate to directories, cd to them, open a terminal there, or open in oil
function M.directories()
  require('snacks.picker').pick {
    source = 'Directories',
    ---@param opts snacks.picker.Config
    ---@param ctx snacks.picker.finder.ctx
    finder = function(opts, ctx)
      local filter = ctx.filter
      local cwd = vim.fs.normalize(opts and opts.cwd or uv.cwd() or ".")
      local cmd, args = get_dir_find_cmd(opts, filter)
      return require("snacks.picker.source.proc").proc(vim.tbl_deep_extend("force", {
        cmd = cmd,
        args = args,
        ---@param item snacks.picker.finder.Item
        transform = function(item)
          item.cwd = cwd
          item.file = item.text
        end,
      }, opts or {}), ctx)
    end,
    -- TODO: update input window title to include cwd
    actions = {
      back = {
        desc = 'Move up/back one directory',
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
      },
      forward = {
        desc = 'Move into selected directory',
        action = function(self, item)
          if not item or item.file == '/' then
            return false
          end
          self.opts.cwd = vim.fs.joinpath(item.cwd, item.file)
          self.input:set('')
          self:find()
          return true
        end,
      },
      cd = {
        desc = 'Move into selected directory',
        action = function(self, item)
          if not item or item.file == '/' then
            return false
          end
          self:close()
          local path = vim.fs.joinpath(item.cwd, item.file)
          vim.cmd('cd ' .. path)
          print("cd -> " .. item.file)
          return true
        end,
      },
      term = {
        desc = 'open a terminal in the selected directory',
        action = function(self, item)
          if not item then return false end
          self:close()
          local path = vim.fs.joinpath(item.cwd, item.file)
          Snacks.terminal.open(nil, {
            cwd = path,
            interactive = true,
          })
        end
      }
    },
    win = {
      input = {
        keys = {
          ['<c-left>'] = { 'back', mode = { 'i', 'n' } },
          ['<c-right>'] = { 'forward', mode = { 'i', 'n' } },
          ['<c-e>'] = { 'cd', mode = { 'i', 'n' } },
          ['<c-t>'] = { 'term', mode = { 'i', 'n' } },
        },
      },
    },
    on_show = function(self)
      self.opts.cwd = vim.uv.cwd()
    end
  }
end

--- list all Lazy plugins, reload, update, open github url in browser
function M.plugins()
  local items = vim.tbl_map(
    function(plugin)
      -- dir = "/home/miles/.local/share/nvim/lazy/nvim-dap-go",
      -- name = "nvim-dap-go",
      -- url = "https://github.com/leoluz/nvim-dap-go.git",

      local readmes = {
        'README.md',
        'readme.md',
        'README.markdown',
        'README.adoc',
        'README.org',
        'readme.org',
      }

      local file
      for _, r in ipairs(readmes) do
        local readme = vim.fs.joinpath(plugin.dir, r)
        if uv.fs_stat(readme) then
          file = r
          break
        end
      end

      return {
        text = plugin.name,
        file = file,
        cwd  = plugin.dir,
        url  = plugin.url,
      }
    end,
    require('lazy').plugins())

  require('snacks.picker').pick {
    source = 'Plugins',
    items = items,
    actions = {
      update = {
        desc = 'update the selected plugin',
        action = function(self, item)
          if not item then return false end
          self:close()
          -- for some reason this doesn't work with two arguments, it needs to
          -- be passed as one string
          vim.cmd({ cmd = 'Lazy', args = { 'update ' .. item.text } })
        end
      },
      reload = {
        desc = 'reload the selected plugin',
        action = function(self, item)
          if not item then return false end
          self:close()
          -- for some reason this doesn't work with two arguments, it needs to
          -- be passed as one string
          vim.cmd({ cmd = 'Lazy', args = { 'reload ' .. item.text } })
        end
      },
      term = {
        desc = 'reload the selected plugin',
        action = function(self, item)
          if not item then return false end
          self:close()
          Snacks.terminal.open(nil, {
            cwd = item.cwd,
            interactive = true,
          })
        end
      },
      open_url = {
        desc = 'open the url of the selected plugin with vim.ui.open',
        action = function(self, item)
          if not item then return false end
          self:close()
          vim.ui.open(item.url)
        end
      },
    },
    win = {
      input = {
        keys = {
          ['<c-s>'] = { 'update',   mode = { 'i', 'n' } },
          ['<c-r>'] = { 'reload',   mode = { 'i', 'n' } },
          ['<c-t>'] = { 'term',     mode = { 'i', 'n' } },
          ['<c-o>'] = { 'open_url', mode = { 'i' } },
          ['o']     = { 'open_url', mode = { 'n' } },
        },
      },
      list = {
        keys = {
        },
      },
    },
    format = 'text',
  }
end

---@type Snacks.pickers.custom
return M
