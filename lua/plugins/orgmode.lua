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
}

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
function _G.org.file_get_property(path, property)
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
local function org_headlines_picker(level)
  local success, picker = pcall(require, 'snacks.picker')
  assert(success, 'ORG :: snacks.picker must be enabled for this functionality')

  local max_level = level or 3
  local items = {}
  for _, file in pairs(require('orgmode').files.all_files) do
    local filename = file.filename:match('/([^/]+)%.org$')
    local title = org.file_get_property(file.filename, 'title') or file:get_directive('title') or ''
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

local function run(c) return ('<cmd>lua %s<cr>'):format(c) end

return {
  {
    'nvim-orgmode/orgmode',
    dependencies = {
      'nvim-orgmode/org-bullets.nvim',
      'hamidi-dev/org-list.nvim',
      'michhernand/RLDX.nvim',
      'folke/snacks.nvim',
    },
    specs = {
      {
        'nvim-orgmode/org-bullets.nvim',
        opts = {
          concealcursor = true,
        },
        main = 'org-bullets',
      },
      {
        'hamidi-dev/org-list.nvim',
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
          { '<tab>o', function() org_headlines_picker(0) end, desc = 'ORG: Picker' }
        },
      },
    },
    event = 'VeryLazy',
    ft = { 'org' },
    opts = {
      org_agenda_files = '~/org/**/*',
      org_default_notes_file = '~/org/index.org',
      org_startup_folded = 'content',
      org_hide_emphasis_markers = true,
      org_todo_keywords = { 'TODO(t)', 'DOING(i)', '|', 'WAITING(w)', 'DELEGATED(g)', 'DONE(d)', 'CANCELLED(c)' },
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
        WAITING   = ':foreground orange',
        DELEGATED = ':foreground orange :slant italic',
        DONE      = ':foreground green',
        CANCELLED = ':foreground grey :slant italic',
      },
      org_capture_templates = {},
      mappings = {
        prefix = '<localleader>o',
        org = {
          org_cycle = 'za',
          org_todo = '<localleader>t',
          org_todo_prev = false,
          org_edit_special = '<localleader>e',
        },
      },
    },
    keys = org.map {
      { 'Open Link', '<cr>', function()
        for _, hook in ipairs(org.open.hooks.pre) do
          if hook() == false then
            return
          end
        end

        -- TODO: allow properties to be referenced and expanded in the link target
        -- They can begin with `$`
        require('orgmode').action('org_mappings.open_at_point')

        for _, hook in ipairs(org.open.hooks.post) do
          if hook() == false then
            return
          end
        end
      end },
      { 'New List Item', ';n', run 'require("orgmode").action("org_mappings.meta_return")', 'i' },
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
        },
      },
      bindings = {
        prefix = "<localleader>n",
        find_node = '<localleader>f',
      },
    },
  },
}
