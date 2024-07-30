return {
  { "marko-cerovac/material.nvim", -- good standard dark-theme
    lazy = false,
    opts = {
      contrast = {
        terminal = true, -- Enable contrast for the built-in terminal
        sidebars = false, -- Enable contrast for sidebar-like windows ( for example Nvim-Tree )
        floating_windows = false, -- Enable contrast for floating windows
        cursor_line = true, -- Enable darker background for the cursor line
        non_current_windows = true, -- Enable contrasted background for non-current windows
        filetypes = {}, -- Specify which filetypes get the contrasted (darker) background
      },
      styles = { -- Give comments style such as bold, italic, underline etc.
        comments = { italic = true  },
        strings = { italic = true },
        keywords = { --[[ underline = true ]] },
        functions = { --[[ bold = true, undercurl = true ]] },
        variables = {},
        operators = { bold = true },
        types = { bold = true },
      },
      plugins = { -- Uncomment the plugins that you use to highlight them
        -- Available plugins:
        -- "dap",
        -- "dashboard",
        -- "gitsigns",
        -- "hop",
        -- "indent-blankline",
        -- "lspsaga",
        -- "mini",
        -- "neogit",
        "neorg",
        "nvim-cmp",
        -- "nvim-navic",
        -- "nvim-tree",
        -- "nvim-web-devicons",
        -- "sneak",
        -- "telescope",
        -- "trouble",
        "which-key",
      },
      disable = {
        colored_cursor = true, -- Disable the colored cursor
        borders = true, -- Disable borders between verticaly split windows
        background = false, -- Prevent the theme from setting the background (NeoVim then uses your terminal background)
        term_colors = false, -- Prevent the theme from setting terminal colors
        eob_lines = false, -- Hide the end-of-buffer lines
      },
      high_visibility = {
        lighter = false, -- Enable higher contrast text for lighter style
        darker = true, -- Enable higher contrast text for darker style
      },
      lualine_style = "stealth", -- Lualine style ( can be 'stealth' or 'default' )
      async_loading = true, -- Load parts of the theme asyncronously for faster startup (turned on by default)
      custom_colors = nil, -- If you want to override the default colors, set this to a function
      custom_highlights = {}, -- Overwrite highlights with your own
    },
    config = function(_, opts)
      vim.g.material_style = "darker"
      -- vim.g.material_style = "oceanic"
      -- vim.g.material_style = "palenight"
      -- vim.g.material_style = "deep ocean"
      require("material").setup(opts)
    end
  },
  {
    "neanias/everforest-nvim",
    version = false,
    lazy = false,
    priority = 1000, -- make sure to load this before all the other start plugins
    -- Optional; default configuration will be used if setup isn't called.
    main = "everforest",
    opts = {
      italics = true,
      ui_contrast = "high",
      dim_inactive_windows = true,
    },
    config = true,
  },
}
