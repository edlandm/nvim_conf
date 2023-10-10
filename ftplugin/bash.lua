vim.keymap.set("n", "<localleader>E",
  function() vim.cmd("w !bash - ") end,
  { buffer = 0, desc = "evaluate buffer", })
