return {
  "OXY2DEV/markview.nvim",
  lazy = false,      -- Recommended
  -- ft = "markdown" -- If you decide to lazy-load anyway
  priority = 30,
  opts = {
    code_blocks = {
      icons = 'mini'
    },
  },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    -- "nvim-tree/nvim-web-devicons",
  },
  config = function(_, opts)
    require('markview').setup(opts)

    -- provide the Heading command
    --   increase :: increase heading level by one
    --   decrease :: decrease heading level by one
    require('markview.extras.headings').setup()

    -- provide the Editor command for working with code blocks
    --   create :: create a code block under the cursor
    --   edit :: edit the code block under the cursor
    require('markview.extras.editor').setup()
  end,
  keys = {
    { '<F4>',            '<cmd>Markview toggle<cr>',  desc = 'Toggle Markview',  buffer = true },
    { '<localleader>ec', '<cmd>Editor create<cr>',    desc = 'Codeblock Create', buffer = true },
    { '<localleader>ee', '<cmd>Editor edit<cr>',    desc = 'Codeblock Edit',   buffer = true },
    { '<localleader>l',  '<cmd>Heading decrease<cr>', desc = 'Heading decrease', buffer = true },
    { '<localleader>d',  '<cmd>Heading increase<cr>', desc = 'Heading Increase', buffer = true },
  },
}
