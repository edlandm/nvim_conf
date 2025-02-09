local modname = 'pickers'
package.loaded[modname] = {}
local M = package.loaded[modname]

local uv = vim.uv or vim.loop

local commands = {
  fd = { "--type", "d", "--color", "never", "-E", ".git" },
  find = { ".", "-type", "d", "-not", "-path", "*/.git/*" },
}

---@param opts { hidden:boolean, ignored:boolean, follow:boolean }:snacks.picker.Config
---@param filter snacks.picker.Filter
local function get_dir_find_cmd(opts, filter)
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

  return cmd, args
end

function M.directories()
  local picker = require('snacks.picker')
  picker.pick {
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
          dd(item)
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

return M
