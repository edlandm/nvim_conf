return {
  'michhernand/RLDX.nvim',
  ft = { 'org' },
  opts = {
    ---@diagnostic disable
    db_filename = vim.fs.joinpath(vim.fn.stdpath('data'), 'rolodex.db.json')
  },
}
