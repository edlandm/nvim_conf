local pref = function(s)
  return ('<leader>o%s'):format(assert(s, 'argument required'))
end

local function init()
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
  }

  for k, v in pairs {
    [pref 'b']  = conf.background,
    [pref 'C']  = conf.third_party.cloak,
    [pref 'cC'] = conf.conceal_cursor,
    [pref 'cc'] = conf.cursorcolumn,
    [pref 'cL'] = conf.conceallevel,
    [pref 'cl'] = conf.cursorline,
    [pref 'cv'] = conf.third_party.csvview,
    [pref 'd']  = conf.diagnostics,
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
  'folke/snacks.nvim',
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern  = "VeryLazy",
      callback = init,
    })
  end,
}
