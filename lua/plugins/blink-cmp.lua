return {
  'saghen/blink.cmp',
  lazy = false,
  build = 'cargo build --release',
  version = '*',
  dependencies = {
    { 'saghen/blink.compat', opts = { version = '*', opts = {}, } },
    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip',
    'xzbdmw/colorful-menu.nvim', -- this makes it prettier
    'saghen/blink.cmp',
  },
  opts = {
    -- for keymap, all values may be string | string[]
    -- use an empty table to disable a keymap
    keymap = {
      preset = 'default',
      ['<Right>'] = { 'select_and_accept', 'fallback' },
      ['<Up>'] = { 'select_prev', 'fallback' },
      ['<Down>'] = { 'select_next', 'fallback' },

      ['<C-Right>'] = { 'snippet_forward', 'fallback' },
      ['<C-Left>'] = { 'snippet_backward', 'fallback' },

      ['<Tab>'] = {},
      ['<S-Tab>'] = {},
    },

    completion = {
      documentation = {
        auto_show = true,
      },
      ghost_text = {
        enabled = true,
      },
      trigger = {
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
      default = { 'snippets', 'path', 'lsp', 'buffer', 'codeium' },
      providers = {
        snippets = {
          score_offset = 2,
        },
        codeium = {
          name = 'codeium',
          module = 'blink.compat.source',
          score_offset = 1,
        },
      },
      cmdline = { 'path' }
    },

    fuzzy = {
      -- frencency tracks the most recently/frequently used items and boosts the score of the item
      use_frecency = true,
      -- proximity bonus boosts the score of items with a value in the buffer
      use_proximity = true,
      -- controls which sorts to use and in which order, these three are currently the only allowed options
      sorts = { 'label', 'kind', 'score' },

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
