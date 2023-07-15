-- live-preview markdown files in browser
return {
  'iamcco/markdown-preview.nvim',
  build = ":call mkdp#util#install()",
  ft = { 'markdown' },
}
