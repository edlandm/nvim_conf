-- set environment variables given a <range> of key=value pairs
vim.api.nvim_create_user_command('SetEnv', function(opts)
  local top, bottom
  if opts.range == 2 then
    top = opts.line1
    bottom = opts.line2
  elseif opts.range == 1 then
    top = opts.line1
    bottom = opts.line1
  else
    top = 1
    bottom = vim.api.nvim_buf_line_count(0)
  end

  assert(top <= bottom, 'line1 must be less than or equal to line2')
  assert(top >= 0, 'line1 must be greater than or equal to 0')

  if top > 0 then
    top = top - 1
  end

  if bottom == 0 then
    bottom = 1
  end

  local lines = vim.api.nvim_buf_get_lines(0, top, bottom, true)
  assert(#lines > 0, 'unexpected empty list of lines')

  for _, line in ipairs(lines) do
    local key, val = string.match(vim.trim(line), '([^#%s]%S-)=(%S.-)$')
    if key then
      if val:sub(1, 1) == "'" and val:sub(-1, -1) == "'" then
        val = val:sub(2, -2)
      end
      vim.fn.setenv(key, val)
    end
  end
end, { desc = 'Set environment variables for a <range> of key=val pairs', range = true })
