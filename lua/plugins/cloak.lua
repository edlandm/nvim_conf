return {
  "laytan/cloak.nvim",
  lazy = false,
  -- event = 'VeryLazy',
  opts = {
    enabled = true,
    cloak_character = '*',
    -- The applied highlight group (colors) on the cloaking, see `:h highlight`.
    highlight_group = 'Comment',
    -- Applies the length of the replacement characters for all matched
    -- patterns, defaults to the length of the matched pattern.
    cloak_length = 10, -- Provide a number if you want to hide the true length of the value.
    -- Wether it should try every pattern to find the best fit or stop after the first.
    try_all_patterns = true,
    patterns = {
      {
        file_pattern = { '*.env*', },
        cloak_pattern = { '=.+', },
      },
      {
        file_pattern = { '*.org', },
        cloak_pattern = { 'src_pass{(.+)}', },
        replace = '',
      },
    },
  },
  cmd = {
    'CloakToggle',
    'CloakEnable',
    'CloakDisable',
  },
  keys = {
    {"<leader>C", "<cmd>lua require('cloak').toggle()<cr>", "Toggle Cloak" }
  }
}
