-- do not enable blink in the following filetypes
local blacklist = {
  'typr',
  'org-roam-select',
}

return {
  'saghen/blink.cmp',
  lazy = false,
  build = 'cargo build --release',
  -- tag = 'v1.3.1',
  dependencies = {
    { 'saghen/blink.compat', opts = { version = '*', opts = {}, } },
    'xzbdmw/colorful-menu.nvim', -- this makes it prettier
    -- sources
    'L3MON4D3/LuaSnip',
    'niuiic/blink-cmp-rg.nvim',
    'Exafunction/windsurf.nvim'
  },
  opts = {
    enabled = function ()
      return not vim.tbl_contains(blacklist, vim.bo.filetype)
        and vim.bo.buftype ~= 'prompt'
        and vim.b.completion ~= false
    end,

    -- for keymap, all values may be string | string[]
    -- use an empty table to disable a keymap
    keymap = {
      preset = 'none',
      ['<C-y>'] = { 'select_and_accept', 'fallback' },

      ['<C-n>']  = { 'select_next', 'fallback' },
      ['<Down>'] = { 'select_next', 'fallback' },

      ['<C-p>'] = { 'select_prev', 'fallback' },
      ['<Up>']  = { 'select_prev', 'fallback' },

      ['<C-Right>'] = { 'snippet_forward',  'fallback' },
      ['<C-Left>']  = { 'snippet_backward', 'fallback' },
      ['<Tab>'] = {
        function(cmp)
          if not cmp.snippet_active() then return end
          local ok, ls = pcall(require, 'luasnip')
          if ok and ls and ls.choice_active() then
            ls.change_choice(1)
            return true
          end
        end,
        'fallback',
      },
      ['<S-Tab>'] = {
        function(cmp)
          if not cmp.snippet_active() then return end
          local ok, ls = pcall(require, 'luasnip')
          if ok and ls and ls.choice_active() then
            ls.change_choice(-1)
            return true
          end
        end,
        'fallback',
      },

      -- ['<C-s>']     = { function(cmp) cmp.show({ providers = { 'snippets' } }) end },
      ['<C-space>'] = false,
    },

    completion = {
      menu          = { auto_show = true, },
      documentation = { auto_show = true, },
      ghost_text    = { enabled   = true, },
      trigger = {
        prefetch_on_insert = true,
        show_on_blocked_trigger_characters = function()
          if vim.api.nvim_get_mode().mode == 'c' then return {} end
          -- you can also block per filetype, for example:
          -- if vim.bo.filetype == 'markdown' then
          --   return { ' ', '\n', '\t', '.', '/', '(', '[' }
          -- end
          return { ' ', '\n', '\t' }
        end,
        -- when true, will show the completion window when the cursor comes after a trigger character when entering insert mode
        show_on_insert_on_trigger_character = true,
      },
    },

    signature = {
      enabled = true,
      window = {
        treesitter_highlighting = false,
      },
      trigger = {
        enabled = true,
        blocked_trigger_characters = {},
        blocked_retrigger_characters = {},
        -- when true, will show the signature help window when the cursor comes after a trigger character when entering insert mode
        show_on_insert_on_trigger_character = true,
      },
    },

    sources = {
      default = function()
        if vim.b.codeium_enabled then
          return { 'codeium' }
        end

        local providers = { 'path', 'lsp', 'buffer', 'ripgrep' }
        if vim.bo.filetype then
          table.insert(providers, 'lazydev')
          table.insert(providers, 'snippets')
        end
        return providers
      end,
      per_filetype = {
        codecompanion = { 'codecompanion' },
        oil           = { 'path' },
        org           = { 'path', 'buffer', 'rolodex' },
      },
      providers = {
        snippets = {
          score_offset = 2,
        },
        codeium = {
          name = 'Codeium',
          module = 'codeium.blink',
          async = true,
          -- score_offset = 1,
          -- enabled = vim.schedule_wrap(function()
          --   return not (
          --     vim.api.nvim_buf_get_name(0):match('^neorg://code%-block')
          --   )
          -- end)
        },
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          -- make lazydev completions top priority (see `:h blink.cmp`)
          score_offset = 100,
        },
        ripgrep = {
          module = "blink-cmp-rg",
          name = "Ripgrep",
          score_offset = -1,
          -- options below are optional, these are the default values
          ---@type blink-cmp-rg.Options
          opts = {
            -- `min_keyword_length` only determines whether to show completion items in the menu,
            -- not whether to trigger a search. And we only has one chance to search.
            prefix_min_len = 4,
            get_command = function(_, prefix)
              return {
                "rg",
                "--no-config",
                "--json",
                "--word-regexp",
                "--ignore-case",
                "--",
                prefix .. "[\\w_-]+",
                vim.fs.root(0, ".git") or vim.fn.getcwd(),
              }
            end,
            get_prefix = function(context)
              return context.line:sub(1, context.cursor[2]):match("[%w_-]+$") or ""
            end,
          },
          enabled = vim.schedule_wrap(function()
            return not (
              -- I sometimes just open nvim in my homedir to type out an
              -- email in a scratch buffer, and running ripgrep in my homedir ends
              -- up taking a lot of RAM.
              vim.bo.filetype == ''
            )
          end)
        },
        rolodex = {
          name = 'rolodex',
          module = 'blink.compat.source',
          should_show_items = function(ctx)
            return ctx.trigger.initial_character == '@'
          end,
          score_offset = 4,
          opts = {
            cmp_name = 'cmp_rolodex',
          },
        },
      }
    },

    cmdline = {
      enabled = true,
      sources = function()
        local type = vim.fn.getcmdtype()
        -- Search forward and backward
        if type == '/' or type == '?' then return { 'buffer' } end
        -- Commands
        if type == '@' then return { 'cmdline' } end
        if type == ':' then
          local cmdline = vim.fn.getcmdline()
          if cmdline:match("^[%%0-9,'<>%.%-]*!") then
            return {}
          elseif cmdline:match("^term") then
            return {}
          end
          return { 'cmdline' }
        end
        return {}
      end,
      completion = {
        trigger = {
          show_on_blocked_trigger_characters = {},
          show_on_x_blocked_trigger_characters = nil, -- Inherits from top level `completion.trigger.show_on_blocked_trigger_characters` config when not set
        },
        menu = {
          auto_show = true, -- Inherits from top level `completion.menu.auto_show` config when not set
          draw = {
            columns = { { 'label', 'label_description', gap = 1 } },
          },
        }
      },
    },

    fuzzy = {
      -- frencency tracks the most recently/frequently used items and boosts the score of the item
      frecency = { enabled = true },
      -- proximity bonus boosts the score of items with a value in the buffer
      use_proximity = true,

      prebuilt_binaries = {
        -- Whether or not to automatically download a prebuilt binary from github. If this is set to `false`
        -- you will need to manually build the fuzzy binary dependencies by running `cargo build --release`
        download = false,
        -- When downloading a prebuilt binary force the downloader to resolve this version. If this is uset
        -- then the downloader will attempt to infer the version from the checked out git tag (if any).
        --
        -- Beware that if the FFI ABI changes while tracking main then this may result in blink breaking.
        forceVersion = nil,
      },
    },

    snippets = { preset = 'luasnip' },

    appearance = {
      -- set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono',
    },
  },
  config = function (_, opts)
    local menu = require('colorful-menu')
    require('blink.cmp').setup(vim.tbl_deep_extend('keep', opts, {
      completion = {
        menu = {
          draw = {
            -- We don't need label_description now because label and label_description are already
            -- combined together in label by colorful-menu.nvim.
            columns = { { "kind_icon" }, { "label", gap = 1 } },
            components = {
              label = {
                text = menu.blink_components_text,
                highlight = menu.blink_components_highlight,
              },
            },
          }
        }
      }
    }))
  end
}
