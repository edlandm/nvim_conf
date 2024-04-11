return {
  'hrsh7th/nvim-cmp',
  event = "InsertEnter",
  dependencies = {
    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip',
    'neovim/nvim-lspconfig',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'dmitmel/cmp-cmdline-history',
    'andersevenrud/cmp-tmux',
    -- 'hrsh7th/cmp-copilot',
    'jcdickinson/codeium.nvim',
  },
  config = function()
    local cmp = require('cmp')
    local luasnip = require('luasnip')

    cmp.setup({
      snippet = {
       -- snippet engine
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      completion = {
        completeopt = 'menu,menuone,noselect'
      },
      window = {
        -- completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered(),
      },
      mapping = cmp.mapping.preset.insert({
        ['<c-n>'] = cmp.mapping.select_next_item(),
        ['<c-p>'] = cmp.mapping.select_prev_item(),
        ['<c-y>']  = cmp.mapping.confirm({ select = true }),
        ['<c-e>'] = cmp.mapping.abort(),
        ['<c-u>'] = cmp.mapping.scroll_docs(-4),
        ['<c-d>'] = cmp.mapping.scroll_docs(4),
        --
        -- <c-l> will move you to the right of each of the expansion locations.
        -- <c-h> is similar, except moving you backwards.
        ['<C-l>'] = cmp.mapping(function()
          if luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          end
        end, { 'i', 's' }),
        ['<C-h>'] = cmp.mapping(function()
          if luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          end
        end, { 'i', 's' }),
      }),
      sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        -- { name = 'copilot' },
        { name = 'codeium' },
        { name = 'path' },
        { name = 'buffer' },
      },
    })

    -- Set configuration for specific filetype.
    cmp.setup.filetype('gitcommit', {
      sources = cmp.config.sources({
        { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
      }, {
          { name = 'buffer' },
          { name = 'tmux' },
        })
    })

    -- Set configuration for specific filetype.
    cmp.setup.filetype('norg', {
      sources = cmp.config.sources({
        { name = 'neorg' },
        { name = 'luasnip' },
        { name = 'buffer' },
        { name = 'path' },
        { name = 'tmux',
          option = {
            -- Source from all panes in session instead of adjacent panes
            all_panes = true,
            -- Completion popup label
            label = '[tmux]',
          },
        },
      })
    })

    -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline({ '/', '?' }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = 'buffer' },
        { name = 'cmdline_history' },
      }
    })

    -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = 'path' },
        { name = 'cmdline',
          option = {
            ignore_cmds = { 'Man', '!', 'write', 'DB', 's', 'g'},
          },
        },
        -- { name = 'cmdline_history' },
      })
    })

      -- Set up lspconfig.
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    require('lspconfig')['rust_analyzer'].setup {
      capabilities = capabilities
    }
  end,
}
