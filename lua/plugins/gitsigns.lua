return {
  'lewis6991/gitsigns.nvim',
  lazy = false,
  opts = {
    signcolumn = true,
    word_diff = true,
    current_line_blame = false,
    trouble = false,
    on_attach = function(bufnr)
      local gs = require('gitsigns')

      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      -- Navigation
      map('n', ']h', function()
        if vim.wo.diff then return ']h' end
        vim.schedule(function() gs.next_hunk() end)
        return '<Ignore>'
      end, {expr=true, desc = "Hunk forward (git diff)"})

      map('n', '[h', function()
        if vim.wo.diff then return '[h' end
        vim.schedule(function() gs.prev_hunk() end)
        return '<Ignore>'
      end, {expr=true, desc = "Hunk backward (git diff)"})

      -- Text object
      map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')

      map('n', 'dq', gs.setqflist, { desc = 'Send diff-hunks to quickfix' })
    end
  },
}
