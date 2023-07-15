return {
  'nvim-treesitter/nvim-treesitter',
  version = false,
  event = { "BufReadPost", "BufNewFile" },
  build = ':TSUpdate',
  cmd = { "TSUpdateSync" },
  dependencies = {
    { 'romgrk/nvim-treesitter-context',
      opts = {
        enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
        max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
        trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
        patterns = { -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
          -- For all filetypes
          -- Note that setting an entry here replaces all other patterns for this entry.
          -- By setting the 'default' entry below, you can control which nodes you want to
          -- appear in the context window.
          default = {
            'class',
            'function',
            'method',
            'for',
            'while',
            'if',
            -- 'switch',
            -- 'case',
          },
          -- Patterns for specific filetypes
          -- If a pattern is missing, *open a PR* so everyone can benefit.
          tex = {
            'chapter',
            'section',
            'subsection',
            'subsubsection',
          },
          rust = {
            'impl_item',
            'struct',
            'enum',
          },
          scala = {
            'object_definition',
          },
          vhdl = {
            'process_statement',
            'architecture_body',
            'entity_declaration',
          },
          markdown = {
            'section',
          },
          elixir = {
            'anonymous_function',
            'arguments',
            'block',
            'do_block',
            'list',
            'map',
            'tuple',
            'quoted_content',
          },
          sh = {
            '^[%w_]+%(%)%s*%{.*$',
          },
          fennel = {
            'fn',
            'macro',
          }
        },
        exact_patterns = {
          -- Example for a specific filetype with Lua patterns
          -- Treat patterns.rust as a Lua pattern (i.e "^impl_item$" will
          -- exactly match "impl_item" only)
          -- rust = true,
          sh = true,
          -- fennel = true,
        },
      }
    },
    'p00f/nvim-ts-rainbow',
  },
  opts = {
    highlight = {
      enable = true
    },
    indent = {
      enable = true
    },
    rainbow = {
      enable = true,
      -- Also highlight non-bracket delimiters like html tags, boolean or
      -- table: lang -> boolean
      extended_mode = true,
      max_file_lines = 5000, -- Do not enable for files with more than n lines, int
    },
    ensure_installed = {
      "bash",
      "c",
      "css",
      "fennel",
      "html",
      "javascript",
      "json",
      "latex",
      "lua",
      "luadoc",
      "luap",
      "make",
      "markdown",
      "markdown_inline",
      "norg",
      "python",
      "regex",
      "rust",
      "sql",
      "typescript",
      "vim",
      "vimdoc",
      "yaml",
    },
  },
  main = "nvim-treesitter.configs",
}
