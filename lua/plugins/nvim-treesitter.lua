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
          },
          go = {
            'function_declaration',
            'method_declaration',
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
  },
  opts = {
    highlight = {
      enable = true
    },
    indent = {
      enable = true,
      disable = { "sql", "c_sharp" },
    },
    ensure_installed = {
      "bash",
      "c",
      "css",
      "c_sharp",
      "fennel",
      "html",
      "java",
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
