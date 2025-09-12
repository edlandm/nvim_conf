require 'resize.main'

vim.keymap.set({ 'n' }, '<Plug>(ResizeMode)', function()
  local resize = require 'resize'
  if not resize.RESIZE_MODE then
    vim.notify('resize.nvim :: missing dependency: debugloop/layers.nvim', vim.log.levels.ERROR, { key = name })
    return
  end

  if not resize.RESIZE_MODE:active() then
    resize.RESIZE_MODE:activate()
  end
end)
