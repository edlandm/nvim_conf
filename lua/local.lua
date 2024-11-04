---- Set Environment
local home = vim.env.HOME
local paths = {
  "bin",
  ".local/bin",
  ".local/go/bin",
  ".cargo/bin",
  ".dotnet/tools",
}
local path = ""
for _,p in ipairs(paths) do
  path = path .. home .. "/" .. p .. ":"
end
vim.env.PATH = path .. vim.env.PATH

vim.g.clipboard = {
  name = "WslClipboard",
  copy = {
    ["+"] = "clip.exe",
    ["*"] = "clip.exe",
  },
  paste = {
    ["+"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    ["*"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
  },
  cache_enabled = 0,
}
----

---- Functions
--- @alias mode "light" | "dark
--- @alias theme { colo: string, tmuxline: string? }
--- @alias colorschemes table<mode, theme>

--- @type colorschemes
local colorschemes = {
  dark = {
    colo     = "everforest",
    tmuxline = "vim_statusline_3",
  },
  light = {
    colo     = "everforest",
    tmuxline = "vim_statusline_3",
  },
}

--- set background, colorscheme, and Tmuxline (if applicable) to either light
--- or dark mode
--- @param mode mode "light" or "dark
--- @param themes colorschemes
local function setmode(mode, themes)
  assert(mode == "light" or mode == "dark", "mode must be either 'light' or 'dark'")

  local theme = assert(themes[mode], mode .. " theme not set")

  vim.o.background = mode
  vim.cmd("silent! colo " .. (theme.colo or "default"))

  local istmux = vim.fn.empty(vim.fn.getenv("TMUX")) == 0
  if istmux and vim.fn.exists(":Tmuxline") and theme.tmuxline then
    vim.cmd("Tmuxline " .. theme.tmuxline)
  end
end

--- call islightmode script and determine whether to switch to light
--- or dark mode (or do nothing if already in that mode)
--- the mode is changed using the setmode function
--- @see setmode
local function changemode()
  local cmd = "/home/miles/bin/islightmode"
  local oldcolo = vim.g.colors_name
  local oldmode = vim.o.background

  local on_exit = function (obj)
    assert(obj, cmd .. " failed to run")
    assert(obj.code == 0, cmd .. " errored with code " .. obj.code)
    local stdout = obj.stdout
    assert(stdout == "0" or stdout == "1", cmd .. " did not return 0 or 1. Got: " .. stdout)
    local islightmode = stdout == "1"

    local mode = "dark"
    if islightmode then
      mode = "light"
    end

    if mode == oldmode then
      if islightmode and oldcolo == colorschemes.dark.colo then return end
      if not islightmode and oldcolo == colorschemes.light.colo then return end
    end

    vim.schedule_wrap(function () setmode(mode, colorschemes) end)()
  end

  vim.system({cmd}, { text = true }, on_exit)
end

--- sets the mode either based on the system theme or the given argument
--- @param opts table
--- @see changemode
--- @see setmode
local function cmd_setmode(opts)
  if #opts.fargs == 0 then
    changemode()
    return
  end

  local mode = opts.fargs[1]
  assert(mode == "light" or mode == "dark", "mode must be either 'light' or 'dark'")
  setmode(mode, colorschemes)
end
----

---- Autocmds
local lightmode_group = vim.api.nvim_create_augroup("lightmode", { clear = true })
vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained" }, { group = lightmode_group, callback = changemode })
----

---- User Commands
vim.api.nvim_create_user_command("SetMode", cmd_setmode, {
    desc = "set light or dark mode",
    nargs = "?",
    complete = function () return { "light", "dark" } end
  })
----

if vim.g.colors_name == nil then
  setmode(vim.o.background or "dark", colorschemes)
end
