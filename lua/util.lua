local api = vim.api
local fun = vim.fn

---returns true if x is not null or empty
---@param x string | any[]
---@return boolean
local function not_empty(x)
  return x ~= nil and fun.empty(x) == 0
end

---echo a `msg` with error highlighting
---@param msg string
local echo_error = function (msg)
  api.nvim_echo({ { msg, 'ErrorMsg' } }, false, {})
end

---@class Ok<T>: [nil, T]
---@alias Err [string, nil]
---@class Result<T>: Ok<T> | Err

---call one of two callbacks, depending on the result
---@generic T, A, B: any
---@param result Result<T>
---@param resolve fun(result: T): A?
---@param reject fun(string): B?
---@return (A | B)?
local function try(result, resolve, reject)
  local err, val = result[1], result[2]
  if err then return reject(err) end
  return resolve(val)
end

---prompt for input then call `callback` on the response
---@param _prompt string | { prompt: string, cancelreturn: string }
---@param callback fun(response: string)
local function prompt(_prompt, callback)
  assert(_prompt, "prompt required")
  assert(callback, "callback required")

  local opts
  if type(_prompt) == 'string' then
    opts = { prompt = _prompt, cancelreturn = '<CANCELRETURN>' }
  else
    opts = _prompt
  end

  local response = fun.input(opts)
  if response == '<CANCELRETURN>' then return end
  callback(response)
end

---prompt the user for a yes/no response and return true if yes, else false
---@param msg string
---@param default boolean
---@return boolean
local function prompt_yn(msg, default)
  assert(msg, 'msg is required')
  if default == nil then default = false end

  local prompt = '*&Yes*\n&No'
  if default == false then
    prompt = '&Yes\n*&No*'
  end

  local default_choice = 1
  if default == false then
    default_choice = 2
  end

  local response = fun.confirm(msg, prompt, default_choice, 'Question')
  if response == 1 then
    return true
  end
  return false
end

---send a basic get request using curl and call `res` on  results if successful
---@param url string
---@param res fun(response: string) success callback (resolve)
---@param rej fun(err: string) error callback (reject)
---@param opts table? curl options
local function curl(url, res, rej, opts)
  assert(url, "url required")
  assert(res, "resolution callback required")
  assert(rej, "rejection callback required")

  ---TODO: lots of opportunity to expand functionality as needed
  opts = opts or {}

  local stdout = vim.uv.new_pipe()
  local stderr = vim.uv.new_pipe()

  local output = ""
  local error = ""

  vim.uv.spawn("curl", {
    args = { "-s", url },
    stdio = { nil, stdout, stderr },
  }, function(code, signal)
      stdout:read_stop()
      stdout:close()
      stderr:close()
      stderr:read_stop()

      if code ~= 0 then
        echo_error("curl exited unexpectedly: " .. code .. " " .. signal)
      end

      if error ~= "" then
        rej(error)
      end

      if output ~= "" then
        res(output)
      end
    end)

  vim.uv.read_start(stdout, function(err, data)
    assert(not err, err)
    output = output .. (data or "")
  end)

  vim.uv.read_start(stderr, function(err, data)
    assert(not err, err)
    error = error .. (data or "")
  end)
end

---run a set of unit-tests on a function
---@generic A : any
---@generic B : any
---@param name string
---@param fn fun(input: A): B
---@param tests { input: A, expected: B }[]
---@return boolean
local function test(name, fn, tests)
  local run = function (input, expected)
    local actual = fn(input)
    local returned_type = type(actual)
    local expected_type = type(expected)
    assert(returned_type == expected_type,
      "ERR: "..name.."("..vim.inspect(input)..") bad return type :: expected: "..expected_type..", got: "..returned_type)

    if vim.deep_equal(actual, expected) then return nil end

    local err = "ERR: "..name.."("..vim.inspect(input)..")"
    .. " :: expected: '"..vim.inspect(expected).."', got: '"..vim.inspect(actual).."'"
    return err
  end

  local all_passed = true
  print("Testing "..name.."():")
  for i, t in ipairs(tests) do
    local msg = i .. ": "
    local err = run(t.input, t.expected)

    if err then
      all_passed = false
      msg = msg .. err
    else
      msg = msg .. "PASS: "..name.."("..vim.inspect(t.input)..") -> " .. vim.inspect(t.expected)
    end

    print(msg)
  end

  return all_passed
end

---apply the current line's indent to each given line
---@param lines string[]
local function indent_lines(lines)
  local linenum = vim.fn.line(".")
  local indent_count = vim.fn.indent(linenum)
  assert(indent_count > 0, "invalid line")

  ---@type string
  local indent = vim.fn["repeat"](" ", indent_count)
  ---@type string[]
  local _lines = {}
  for _, line in ipairs(lines) do
    _lines[#_lines + 1] = indent .. line
  end
  return _lines
end

return {
  curl         = curl,
  echo_error   = echo_error,
  indent_lines = indent_lines,
  not_empty    = not_empty,
  prompt       = prompt,
  prompt_yn    = prompt_yn,
  test         = test,
  try          = try,
}
