local util = require('util')

---@class org.conf
---@field open org.open.conf

---@class org.open.conf
---@field hooks org.open.hooks

---@class org.open.hooks
---@field pre  org.open.hook[] these functions are called before opening the link
---returning false stops further hook execution and blocks opening the link
---@field post org.open.hook[] these functions are called after opening the link
---returning false stops further hook execution

---@alias org.open.hook fun():boolean?

_G.org = {
  open = {
    hooks = {
      pre  = {},
      post = {},
    },
  },
  fn = {},
  pickers = {},
}

---- FUNCTIONS ===============================================================
---return a dictionary of all properties cascaded to the current section
---@param file? OrgFile org file object (default to current file)
---@param cursor? [integer, integer] (1,0)-based tuple of lnum and col
---@return table<string, string> dictionary of all properties applicable to the nearest section/headline
function org.fn.get_properties_at_cursor(file, cursor)
  if not file then
    file = require'orgmode'.files:get_current_file()
  end
  assert(file.get_closest_headline, 'file must be instance of OrgFile')

  if cursor then
    assert(#cursor, 'cursor must be (1, 0) tuple')
  end

  local headline = file:get_closest_headline(cursor)
  local properties = vim.tbl_deep_extend('force', (file:get_properties()), (headline:get_properties()))
  return properties
end

---expand any properties in the given string
---@param s string
---@param properties? table<string,string> dictionary of properties to expand
---  (default to all applicable properties of the section under the cursor)
---@return string `s` with all properties expanded
function org.fn.expand_properties(s, properties)
  if not s:match(':') then return s end

  if not properties then
    properties = org.fn.get_properties_at_cursor()
  end

  while s:match(':[^:]+:') do
    for prop in s:gmatch(':([^:]+):') do
      local val = properties[prop:lower()]
      assert(val, 'undefined property: ' .. prop)
      s = s:gsub(':' .. prop .. ':', val)
    end
  end

  return s
end

---cd to the :PWD: property of the given org file (if set)
---if the directory does not exist, offer to create it
---  - detect if the directory is being created in a git bare repository and if
---    so create a new worktree.
function org.fn.cd_to_pwd()
  local properties = org.fn.get_properties_at_cursor()
  local pwd = org.fn.expand_properties(properties.pwd, properties)

  if not pwd or vim.trim(pwd) == '' then
    vim.notify('org-mode :: No :PWD: Property set', "warn", {})
    return
  end

  pwd = vim.fn.expand(pwd)

  local stat, err, errname = vim.uv.fs_stat(pwd)
  if err then
    if errname == 'ENOENT' then
      if not require('util').prompt_yn(('%s not found, would you like to create it?'):format(pwd), false) then
        return
      end

      -- check if the parent directory is a git bare directory
      local parent = vim.fs.dirname(pwd)
      local is_git_dir = vim.fn.isdirectory(parent .. '/worktrees')
      local cmd = ('mkdir -p %s'):format(pwd)
      if is_git_dir == 1 then
        cmd = ('git -C %s worktree add %s'):format(parent, vim.fs.basename(pwd))
      end

      ---@diagnostic disable-next-line: param-type-mismatch
      local ok = os.execute(cmd)
      if not ok then
        vim.notify('Unable to create ' .. pwd, vim.log.levels.ERROR, {})
        return
      end

      if is_git_dir == 1 then
        vim.notify('Created git worktree: ' .. pwd, vim.log.levels.INFO, {})
      else
        vim.notify('Created directory: ' .. pwd, vim.log.levels.INFO, {})
      end

      stat = vim.uv.fs_stat(pwd)
    else
      error(err)
    end
  end

  if stat and stat.type ~= 'directory' then
    vim.notify(pwd .. ' is not a directory', vim.log.levels.ERROR, {})
    return
  end

  util.cd(pwd)
end

---create hard link from current file to :PWD:/index.org
function org.fn.link_to_pwd()
  local path = vim.fn.expand('%:p')
  local properties = org.fn.get_properties_at_cursor()
  local pwd = org.fn.expand_properties(properties.pwd, properties)
  if not (pwd and vim.fn.isdirectory(vim.fn.expand(pwd)) == 1) then
    return
  end

  local index_file = vim.fs.joinpath(vim.fn.expand(pwd), 'index.org')
  if vim.uv.fs_stat(index_file) then
    print(('Org-Mode :: %s already exists'):format(index_file))
    return
  end

  local on_exit = function(obj)
    print(obj.code)
    print(obj.signal)
    print(obj.stdout)
    print(obj.stderr)
  end

  vim.system({ 'ln', path, index_file }, {}, on_exit):wait()
  print(('Org-Mode :: Linked %s -> %s'):format(path, index_file))
end

function org.fn.selection_to_link()
  -- leave visual mode so that '< and '> get set
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes('<esc>', true, false, true),
    'itx',
    false)
  local s = vim.api.nvim_buf_get_mark(0, '<')
  local e = vim.api.nvim_buf_get_mark(0, '>')
  local clip = vim.fn.getreg('+', false):gsub('\n', '')
  local label = vim.api.nvim_buf_get_text(0, s[1]-1, s[2], e[1]-1, e[2]+1, {})
  local text = ('[[%s][%s]]'):format(clip, table.concat(label, '\n'))
  vim.api.nvim_buf_set_text(0, s[1]-1, s[2], e[1]-1, e[2]+1, { text })
  -- vim.cmd.normal('V')
end

---insert a new section or subsection after the current section
---@param opts? { win?:integer, buf?:integer, pos?:[integer,integer], is_subsection?:boolean }
function org.fn.insert_new_section(opts)
  opts = opts or {}
  local win      = opts.win or 0
  local buf      = opts.buf or 0
  local pos      = opts.pos
  if not pos then
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    pos = { row - 1, col }
  end
  local node     = vim.treesitter.get_node({ bufnr = buf, pos = pos })
  assert(node, 'no node found under cursor or given position')
  local section  = require('util').find_node_ancestor({'section'}, node)
  assert(section, 'unable to find section node before cursor')
  local headline = assert(section:child(0), 'no headline found in section')
  local stars    = assert(headline:child(0), 'no stars found in section headline')

  local text = vim.treesitter.get_node_text(stars, buf)
  if opts.is_subsection then
    text = text .. '*'
  end
  text = text .. ' '

  local _, _, insert_at, _ = section:range()
  vim.api.nvim_buf_set_lines(buf, insert_at, insert_at, false, {text})
  vim.api.nvim_win_set_cursor(win, { insert_at+1, #text + 1 })
end

---expand any properties in the link at the cursor
---@return string? return the link target with any properties expanded
function org.fn.expand_link_path()
  local hyperlink = require'orgmode.org.links.hyperlink'.at_cursor()
  assert(hyperlink, 'no link found at cursor')
  local path = hyperlink.url:get_path()
  return org.fn.expand_properties(path)
end

---shorthand for creating keymaps in a format that I prefer
---@param maps [string,string,string|function][]
function _G.org.map(maps)
  local mappings = {}
  for _, map in ipairs(maps) do
    local desc, lhs, rhs, mode = unpack(map)
    table.insert(mappings, { lhs, rhs, desc = desc, mode = mode or 'n', ft = 'org' })
  end
  return mappings
end

---return the value of the given :PROPERTY: (case-insensitive)
---@return string?
function org.fn.file_get_property(path, property)
  local file = require('orgmode').files.all_files[path]
  assert(file, 'org-mode :: file not found in database: ' .. path)
  local _, _, property_drawer = file:get_properties()
  if not property_drawer then return end
  local contents = file:get_node_text_list(property_drawer:field('contents')[1])

  for _, line in ipairs(contents) do
    local property_name, property_value = line:match('^%s*:([^:]-):%s*(.*)$')
    if property_name and property_name:lower() == property:lower() then
      return property_value
    end
  end
end

---picker for Org-mode files and headlines
---@param level integer maximum headline-level to return
function org.pickers.all_headlines(level)
  local success, picker = pcall(require, 'snacks.picker')
  assert(success, 'ORG :: snacks.picker must be enabled for this functionality')

  local max_level = level or 3
  local items = {}
  for _, file in pairs(require('orgmode').files.all_files) do
    local filename = file.filename:match('/([^/]+)%.%S-$')
    local title = org.fn.file_get_property(file.filename, 'title') or file:get_directive('title') or ''
    table.insert(items, {
      file = file.filename,
      filename = filename,
      title = title,
      text = filename .. ' ' .. title,
      preview = {
        text = file.content,
        ft = 'org',
      }
    })
    for _, headline in ipairs(file:get_headlines()) do
      local headline_title, headline_level = headline:get_title()
      local link_target = headline_title:match(']%[(.-)]]')
      local range = headline:get_range()

      if headline_level <= max_level then
        table.insert(items, {
          file     = file.filename,
          filename = filename,
          title    = link_target or headline_title,
          text     = filename .. ' ' .. (link_target or headline_title),
          level    = headline_level,
          range = {
            start_line = range.start_line,
            end_line = range.end_line,
          },
          preview = {
            text = table.concat(file.lines, '\n', range.start_line, range.end_line),
            ft = 'org',
          }
        })
      end
    end
  end

  picker.pick {
    source  = 'ORG-MODE',
    title  = 'Org-Mode',
    actions = {
      split = function(self, item)
        self:close()
        vim.cmd('split ' .. item.file)
        if item.range then
          vim.cmd(item.range.start_line)
        end
      end,
      vsplit = function(self, item)
        self:close()
        vim.cmd('vert split ' .. item.file)
        if item.range then
          vim.cmd(item.range.start_line)
        end
      end,
    },
    confirm = function(self, item)
      self:close()
      if not item then return end
      vim.cmd('edit ' .. item.file)
      if item.range then
        vim.cmd(item.range.start_line)
      end
    end,
    items   = items,
    preview = 'preview',
    format  = function(item)
      if not item.level then
        return {
          { item.filename, 'SnacksPickerDimmed' },
          { ' ' },
          { item.title, 'SnacksPickerFile' },
        }
      end
      return {
        { item.filename, 'SnacksPickerDimmed' },
        { ' ' },
        { string.rep('*', item.level - 1), 'SnacksPickerIdx' },
        { ' ' },
        { item.title, 'SnacksPickerFile' },
      }
    end,
    layout = 'ivy_split',
    win = {
      input = {
        keys = {
          ['<c-s>'] = { 'split', mode = { 'n', 'i' } },
          ['<c-v>'] = { 'vsplit', mode = { 'n', 'i' } },
        },
      },
    },
  }
end

---get all headlines and codeblocks in an org buffer
---@param buf integer buffer id
---@return snacks.picker.finder.Item[]
local function get_headlines(buf)
  local ok, parser = pcall(vim.treesitter.get_parser, buf)
  if not ok or not parser then
    return {}
  end
  parser:parse(true)
  local query = vim.treesitter.query.parse(parser:lang(), [[
      (section
        (headline) @headline)
      (body
        (block . (expr) @block-type) @code-block
        (#eq? @block-type "SRC"))
      ]])

  if not query then
    return {}
  end

  local headlines = {}
  for _, tree in ipairs(parser:trees()) do
    for id, node, meta in query:iter_captures(tree:root(), buf) do
      local name = query.captures[id]
      if name ~= 'block-type' then
        local range = { node:range() }
        local text = vim.treesitter.get_node_text(node, buf, meta)
        local highlights
        if name == 'code-block' then
          -- Extract the language and the code content
          local code_start = '^%s*#%+BEGIN_SRC '
          local code_end = '\n%s*#%+END_SRC%s*'
          local lang = text:match(code_start .. '(%w+)') or 'txt'
          local desc = text:match(lang .. ' ([^\n]*)\n')
          local code_content = text
            :gsub('[^\n]+\n', '', 1) -- remove first line
            :gsub(code_end,   '')    -- trim block end (last line)
            :gsub('^%s*',     '')    -- trim leading spaces
            :gsub('%s',       ' ')   -- replace all whitespace with space
            :gsub('(%s)%s*',  '%1')  -- remove duplicate spaces
          local sep = '::'
          local desc_str = desc and ('['..desc..']') or ''

          ---@type vim.api.keyset.set_extmark|{ col: number, end_col: number, row: number, field: string }[]?
          local code_highlights = Snacks.picker.highlight.get_highlights({ code = code_content, lang = lang })[1]

          highlights = {
            { '├╴',         'SnacksPickerTree' },
            { ' ',          'SnacksPickerIconHeadline' },
            { '#',          '@character.special' },
            { lang:upper(), '@annotation' },
          }
          if #desc_str > 0 then
            table.insert(highlights, { '[',  '@punctuation.delimiter' })
            table.insert(highlights, { desc, '@string' })
            table.insert(highlights, { ']',  '@punctuation.delimiter' })
          end
          table.insert(highlights, { sep, '@punctuation.delimiter' })

          local offset = 0
          for i = 1, #highlights do
            local hl = highlights[i]
            offset = offset + #hl[1]
          end

          if code_highlights then
            for i = 1, #code_highlights do
              local hl = code_highlights[i]
              hl.col     = offset + hl.col
              hl.end_col = offset + hl.end_col
              table.insert(highlights, hl)
            end
          end
          table.insert(highlights, { code_content })
        end

        ---@type snacks.picker.treesitter.Match
        local match = {
          id = node:id(),
          node = node,
          name = name,
          meta = meta,
          text = text,
          pos = { range[1] + 1, range[2] },
          end_pos = { range[3] + 1, range[4] },
          kind = node:type(),
          highlights = highlights,
        }
        table.insert(headlines, match)
      end
    end
  end
  return headlines
end

local function sort_nodes(nodes)
  table.sort(nodes, function(a, b)
    if a.pos[1] ~= b.pos[1] then
      return a.pos[1] < b.pos[1]
    end
    if a.pos[2] ~= b.pos[2] then
      return a.pos[2] < b.pos[2]
    end
    if a.end_pos[1] ~= b.end_pos[1] then
      return a.end_pos[1] < b.end_pos[1]
    end
    return a.end_pos[2] < b.end_pos[2]
  end)
end

---@param opts snacks.picker.treesitter.Config
---@type snacks.picker.finder
local function get_org_symbols(opts, ctx)
  local buf = ctx.filter.current_buf
  local tree = get_headlines(buf)
  local items = {} ---@type snacks.picker.finder.Item[]
  local last = {} ---@type table<snacks.picker.finder.Item,snacks.picker.finder.Item>

  ---@type snacks.picker.finder.Item
  local root = { text = "root" }

  ---@param match snacks.picker.finder.Item
  ---@param parent snacks.picker.finder.Item?
  ---@return snacks.picker.finder.Item?
  local function add(match, parent, depth)
    local item ---@type snacks.picker.finder.Item?
    local kinds = {
      ['headline'] = 'Headline',
      ['block']    = 'Block',
    }
    item = {
      text       = match.text,
      depth      = depth or 0,
      tree       = opts.tree,
      buf        = buf,
      name       = match.text,
      kind       = kinds[match.kind] or 'Unknown',
      ts_kind    = match.kind,
      pos        = match.pos,
      end_pos    = match.end_pos,
      last       = true,
      parent     = parent,
      highlights = match.highlights,
    }
    if parent then
      if last[parent] then
        last[parent].last = false
      end
      last[parent] = item
    end
    items[#items + 1] = item
    if item.kind == 'Block' and item.last then
      -- this is handled by default by other kinds by Snacks.picker.format.lsp_symbol
      ---@diagnostic disable-next-line: assign-type-mismatch
      item.highlights[1][1] = '└╴'
    end
    local children = match.children or {}
    sort_nodes(children)
    for _, child in ipairs(children) do
      local c = add(child, item or parent, depth + 1)
      -- first item in a scope is the scope itself
      if match.kind == "scope" and c and c.depth == depth + 1 then
        item = item or c
      end
    end
    return item
  end

  sort_nodes(tree)

  for _, scope in ipairs(tree) do
    add(scope, root, 0)
  end

  return items
end

function org.pickers.headlines()
  Snacks.picker.treesitter({
    finder = get_org_symbols,
    format = function(item, picker)
      return item.kind == 'Block'
        and item.highlights
        or Snacks.picker.format.lsp_symbol(item, picker)
    end
  })
end

local function run(c) return ('<cmd>lua %s<cr>'):format(c) end

return {
  {
    'nvim-orgmode/orgmode',
    dependencies = {
      'folke/snacks.nvim',
    },
    specs = {
      {
        'nvim-orgmode/org-bullets.nvim',
        ft = { 'org' },
        opts = {
          concealcursor = true,
        },
        main = 'org-bullets',
      },
      {
        'hamidi-dev/org-list.nvim',
        ft = { 'org' },
        dependencies = {
          'tpope/vim-repeat',
        },
        opts = {
          mapping = {
            key = '<localleader>olt',
            desc = 'Toggle: Cycle through list types',
          },
        },
        main = 'org-list',
      },
      {
        'folke/snacks.nvim',
        keys = {
          { '<tab>o', function() org.pickers.all_headlines(0) end, desc = 'ORG: Picker' }
        },
      },
      {
        'michhernand/RLDX.nvim',
        pin = true,
        ft = { 'org' },
        opts = {
          ---@diagnostic disable
          db_filename = vim.fs.joinpath(vim.fn.stdpath('data'), 'rolodex.db.json'),
          encryption = 'plaintext',
          schema_ver = '0.0.2',
        },
      }
    },
    event = 'VeryLazy',
    ft = { 'org' },
    opts = {
      org_agenda_files = '~/org/**/*',
      org_default_notes_file = '~/org/index.org',
      org_startup_folded = 'content',
      org_hide_emphasis_markers = true,
      org_todo_keywords = { 'TODO(t)', 'DOING(i)', '|', 'AMBIGUOUS(a)', 'WAITING(w)', 'DELEGATED(g)', 'DONE(d)', 'CANCELLED(c)' },
      org_use_property_inheritance = true,
      org_blank_before_new_entry = {
        heading = false,
      },
      -- FIXME: currently not able to get this working at all
      -- TODO: I'd like to set these colors to highlight groups if possible
      -- TODO      = ':foreground @comment.error :weight bold',
      -- WAITING   = ':foreground @comment.warning',
      -- DOING     = ':foreground @comment.todo :underline on',
      -- DONE      = ':foreground @comment.note',
      -- CANCELLED = ':foreground @comment :slant italic',
      org_todo_keyword_faces = {
        TODO      = ':foreground red :weight bold',
        DOING     = ':foreground lightgreen :underline on',
        WAITING   = ':foreground yellow',
        DELEGATED = ':foreground yellow :slant italic',
        DONE      = ':foreground green',
        CANCELLED = ':foreground grey :slant italic',
      },
      org_capture_templates = {},
      mappings = {
        prefix = '<localleader>o',
        org = {
          org_cycle           = 'za',
          org_todo            = '<localleader>t',
          org_todo_prev       = false,
          org_edit_special    = '<localleader>e',
          org_priority        = '<localleader>p',
          org_priority_up     = false,
          org_priority_down   = false,
          org_timestamp_up    = false,
          org_timestamp_down  = false,
          org_toggle_checkbox = false,
        },
      },
      hyperlinks = {
        sources = {
          {
            get_name = function() return 'file' end,
            follow = function(_, link)
              local protocol, target = link:match('^(%w+):(.*)$')
              if protocol and protocol ~= 'file' then return false end
              local path = _G.org.fn.expand_properties((target or link))
              local stat, _, err = vim.uv.fs_stat(path)
              if not stat and err ~= 'ENOENT' then
                error(err)
              end
              if stat and stat.type == 'file' and require('util').is_binary_file(path) then
                return false
              end
              vim.cmd({ cmd = 'edit', args = { path } })
              return true
            end,
          }
        }
      },
    },
    keys = org.map {
      { 'Open Link at <cursor>', '<cr>',
        function()
          for _, hook in ipairs(org.open.hooks.pre) do
            if hook() == false then return end
          end

          -- They can begin with `$`
          require('orgmode').action('org_mappings.open_at_point')

          for _, hook in ipairs(org.open.hooks.post) do
            if hook() == false then return end
          end
        end
      },
      { 'New List Item', ';n', run 'require("orgmode").action("org_mappings.meta_return")', 'i' },
      { 'Flash: Open Org Link', '_o',
        function()
          require("flash").jump({
            pattern = '[[',
            action = function(match, state)
              vim.api.nvim_win_set_cursor(match.win, match.pos)
              require('orgmode').action('org_mappings.open_at_point')
            end,
          })
        end,
      }
    }
  },
  {
    "chipsenkbeil/org-roam.nvim",
    main = 'org-roam',
    event = 'VeryLazy',
    -- tag = '0.1.1',
    dependencies = {
      {
        'nvim-orgmode/orgmode',
        -- tag = "0.3.7",
      },
    },
    opts = {
      directory = '~/org/notes',
      org_files = {
        '~/org/index.org',
      },
      extensions = {
        dailies = {
          directory = 'journal',
          templates = {
            d = {
              description = "default",
              template = "%?",
              target = "%<%Y-%m-%d>.org",
            },
          },
          bindings = {
            goto_today        = '<prefix>t',
            goto_tomorrow     = '<prefix>T',
            goto_yesterday    = '<prefix>y',
            capture_today     = '<prefix>dt',
            capture_tomorrow  = '<prefix>dT',
            capture_yesterday = '<prefix>dy',
          },
        },
      },
      bindings = {
        prefix = "<localleader>n",
        find_node = '<localleader>f',
      },
    },
  },
}
