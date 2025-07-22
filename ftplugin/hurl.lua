local function uri_encode_param_value(_lnum)
  local lnum = _lnum or vim.fn.line('.')
  local line = vim.fn.getline(lnum)
  local sep = ': '
  local pieces = vim.split(line, sep)
  local new_val = vim.uri_encode(pieces[2])
  local newline = pieces[1] .. sep .. new_val
  vim.api.nvim_buf_set_lines(0, lnum-1, lnum, true, {newline})
end

local mappings = require 'config.mappings'
mappings.nmap({
  {'Url-encode FormData value on <line>', mappings.lleader('u'), uri_encode_param_value },
})
