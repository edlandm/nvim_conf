local mappings = require 'config.mappings'
local map = mappings.to_lazy
local ll = mappings.lleader

return {
  dir = vim.fs.joinpath(vim.fn.stdpath('config'), 'plugin', 'markdown.nvim'),
  ft = 'markdown',
  specs = {
    {
      -- live-preview markdown files in browser
      'iamcco/markdown-preview.nvim',
      build = ":call mkdp#util#install()",
      ft = { 'markdown' },
      keys = map { ft = 'markdown',
        { 'Markdown Preview', '<F3>', '<cmd>MarkdownPreviewToggle<cr>' },
      },
    },
  },
  opts = {
  },
  keys = map { ft = 'markdown',
    { 'Add List Item',    ll 'l',  '<Plug>(MarkdownAddListItem)' },
    { 'Add List Item',    ';n',    '<Plug>(MarkdownAddListItem)', mode = { 'i' } },
    { 'Append List Item', ll 'L',  '<Plug>(MarkdownAppendListItem)' },
    { 'Append List Item', ';N',    '<Plug>(MarkdownAppendListItem)', mode = { 'i' } },
    { 'Add Task',         ll 't', '<Plug>(MarkdownAddTask)' },
    { 'Add Task',         ';t',    '<Plug>(MarkdownAddTask)', mode = { 'i' } },
    { 'Append Task',      ll 'T', '<Plug>(MarkdownAppendTask)' },
    { 'Append Task',      ';T',    '<Plug>(MarkdownAppendTask)', mode = { 'i' } },
  },
}
