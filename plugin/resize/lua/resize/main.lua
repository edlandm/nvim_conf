local name = 'resize'
package.loaded[name] = {}
local M = package.loaded[name]

local step_sizes = { 1, 5, 10 }

local default_opts = {
  vertical_step_size = 5,
  horizontal_step_size = 5,
  resize_mode = {},
}

-- expand_up expands the window upwards by M.vertical_step_size.
function M.expand_up()
	local above_win_number = vim.fn.winnr("k")
	if above_win_number == vim.fn.winnr() then
		return
	end
	vim.fn.win_move_statusline(above_win_number, -M.opts.vertical_step_size)
end

-- expand_down expands the window downwards by M.opts.vertical_step_size.
function M.expand_down()
	local current_win_number = vim.fn.winnr()
	vim.fn.win_move_statusline(current_win_number, M.opts.vertical_step_size)
end

-- expand_left expands the window to the left by M.opts.horizontal_step_size.
function M.expand_left()
	local left_win_number = vim.fn.winnr("h")
	if left_win_number == vim.fn.winnr() then
		return
	end
	vim.fn.win_move_separator(left_win_number, -M.opts.horizontal_step_size)
end

-- expand_right expands the window to the right by M.opts.horizontal_step_size.
function M.expand_right()
	local current_win_number = vim.fn.winnr()
	vim.fn.win_move_separator(current_win_number, M.opts.horizontal_step_size)
end

-- opposite of expand_up
function M.shrink_up()
	local above_win_number = vim.fn.winnr("k")
	if above_win_number == vim.fn.winnr() then
		return
	end
	vim.fn.win_move_statusline(above_win_number, M.opts.vertical_step_size)
end

-- opposite of expand_down
function M.shrink_down()
  local current_win_number = vim.fn.winnr()
  vim.fn.win_move_statusline(current_win_number, -M.opts.vertical_step_size)
end

-- opposite of expand_left
function M.shrink_left()
  local left_win_number = vim.fn.winnr("h")
  if left_win_number == vim.fn.winnr() then
    return
  end
  vim.fn.win_move_separator(left_win_number, M.opts.horizontal_step_size)
end

function M.shrink_right()
  local current_win_number = vim.fn.winnr()
  vim.fn.win_move_separator(current_win_number, -M.opts.horizontal_step_size)
end

function M.increase_step_size_vert()
  local cur = M.opts.vertical_step_size
  for i = 1, #step_sizes do
    local s = step_sizes[i]
    if s > cur then
      M.opts.vertical_step_size = s
      print('Vertical Step Size: ' .. s)
      break
    end
  end
end

---change the given step size to the next larger/smaller one
---@param dim 'horizontal' | 'vertical'
---@param dir 'positive' | 'negative'
local function update_step_size(dim, dir)
  local key = dim .. '_step_size'
  local step_size = M.opts[key]
  local changed = false
  if dir == 'positive' then
    for i = 1, #step_sizes do
      local s = step_sizes[i]
      if s > step_size then
        step_size = s
        changed = true
        break
      end
    end
  else
    for i = #step_sizes, 1, -1 do
      local s = step_sizes[i]
      if s < step_size then
        step_size = s
        changed = true
        break
      end
    end
  end

  if changed then
    M.opts[key] = step_size
    print(('%s step size: %d'):format(dim, step_size))
  else
    print(('%s step size at limit: %d'):format(dim, step_size))
  end
end

function M.increase_vertical_step_size()
  update_step_size('vertical', 'positive')
end

function M.decrease_vertical_step_size()
  update_step_size('vertical', 'negative')
end

function M.increase_horizontal_step_size()
  update_step_size('horizontal', 'positive')
end

function M.decrease_horizontal_step_size()
  update_step_size('horizontal', 'negative')
end

---use layers.nvim to create a window-resize mode
---@param opts { enable_mapping?:string, keymaps?:table }?
function M.create_resize_mode(opts)
  local ok, layers = pcall(require, 'layers')
  if not ok then
    vim.notify('resize.nvim :: missing dependency: debugloop/layers.nvim', vim.log.levels.ERROR, {})
    return
  end
  local RESIZE_MODE = layers.mode.new()
  RESIZE_MODE:auto_show_help()

  local function enter_resize_mode()
    if not RESIZE_MODE:active() then
      RESIZE_MODE:activate()
    end
  end

  local function exit_resize_mode()
    pcall(RESIZE_MODE.deactivate, RESIZE_MODE)
  end

  opts = vim.tbl_deep_extend('keep', opts or {}, {
    enable_mapping = '<c-w><c-r>',
    keymaps = {
      n = {
        { '<esc>', exit_resize_mode, { desc = 'Exit Resize-Mode' } },
        { 'h', M.expand_left,  { desc = 'Expand Left'  } },
        { 'l', M.expand_right, { desc = 'Expand Right' } },
        { 'j', M.expand_down,  { desc = 'Expand Down'  } },
        { 'k', M.expand_up,    { desc = 'Expand Up'    } },
        { 'H', M.shrink_left,  { desc = 'Shrink Left'  } },
        { 'L', M.shrink_right, { desc = 'Shrink Right' } },
        { 'J', M.shrink_down,  { desc = 'Shrink Down'  } },
        { 'K', M.shrink_up,    { desc = 'Shrink Up'    } },
        { '<', M.decrease_horizontal_step_size, { desc = 'Decrease Horiz Step Size' } },
        { '>', M.increase_horizontal_step_size, { desc = 'Increase Horiz Step Size' } },
        { '(', M.decrease_vertical_step_size, { desc = 'Decrease Vert Step Size' } },
        { ')', M.increase_vertical_step_size, { desc = 'Increase Vert Step Size' } },
      },
    }
  })

  vim.api.nvim_set_keymap('n', opts.enable_mapping, '', {
    desc = 'Enable Resize-Mode', callback = enter_resize_mode
  })
  RESIZE_MODE:keymaps(opts.keymaps)
end

function M.setup(opts)
  M.opts = vim.tbl_deep_extend('keep', opts or {}, default_opts)

  if opts.resize_mode ~= false then
    M.create_resize_mode(opts.resize_mode)
  end
end

return M
