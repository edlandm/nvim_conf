vim.wo.conceallevel  = 2
vim.wo.concealcursor = 'nc'
vim.bo.shiftwidth    = 2
vim.bo.tabstop       = 2
vim.wo.wrap          = false

vim.keymap.set("n", "<CR>", "<Plug>(neorg.esupports.hop.hop-link)", { desc = "neorg: follow link", buffer = true })
vim.keymap.set("n", "<c-w><c-v>", "<Plug>(neorg.esupports.hop.hop-link.vsplit)", { desc = "neorg: open link in vsplit", buffer = true })

vim.keymap.set("n", "<localleader>e", "<Plug>(neorg.looking-glass.magnify-code-block)", { desc = "neorg: edit code-block in new buffer", buffer = true })

vim.keymap.set("x", "<",    "<Plug>(neorg.promo.demote.range)",     { desc = "neorg: demote range",          buffer = true })
vim.keymap.set("n", "<<",   "<Plug>(neorg.promo.demote.nested)",    { desc = "neorg: demote item (nested)",  buffer = true })
vim.keymap.set("n", "< ",   "<Plug>(neorg.promo.demote)",           { desc = "neorg: demote item",           buffer = true })
vim.keymap.set("x", ">",    "<Plug>(neorg.promo.promote.range)",    { desc = "neorg: promote range",         buffer = true })
vim.keymap.set("n", ">>",   "<Plug>(neorg.promo.promote.nested)",   { desc = "neorg: promote item (nested)", buffer = true })
vim.keymap.set("n", "> ",   "<Plug>(neorg.promo.promote)",          { desc = "neorg: promote item",          buffer = true })
vim.keymap.set("i", "<c-d>", "<Plug>(neorg.promo.demote.nested)",  { desc = "neorg: demote item (nested)",      buffer = true })
vim.keymap.set("i", "<c-t>", "<Plug>(neorg.promo.promote.nested)", { desc = "neorg: promote item (nested)",     buffer = true })
vim.keymap.set("i", ";n",    "<Plug>(neorg.itero.next-iteration)", { desc = "neorg: create a noew list/header", buffer = true })

vim.keymap.set("n", "<localleader>li", "<Plug>(neorg.pivot.list.invert)", { desc = "neorg: invert all items in list", buffer = true })
vim.keymap.set("n", "<localleader>lt", "<Plug>(neorg.pivot.list.toggle)", { desc = "neorg: toggle list ordered<->unordered", buffer = true })

vim.keymap.set("n", "<localleader>ta", "<Plug>(neorg.qol.todo-items.todo.task-ambiguous)", { desc = "neorg: set task to ambiguous", buffer = true })
vim.keymap.set("n", "<localleader>tc", "<Plug>(neorg.qol.todo-items.todo.task-cancelled)", { desc = "neorg: set task to cancelled", buffer = true })
vim.keymap.set("n", "<localleader>td", "<Plug>(neorg.qol.todo-items.todo.task-done)",      { desc = "neorg: set task to done",      buffer = true })
vim.keymap.set("n", "<localleader>th", "<Plug>(neorg.qol.todo-items.todo.task-hold)",      { desc = "neorg: set task to hold",      buffer = true })
vim.keymap.set("n", "<localleader>ti", "<Plug>(neorg.qol.todo-items.todo.task-important)", { desc = "neorg: set task to important", buffer = true })
vim.keymap.set("n", "<localleader>tp", "<Plug>(neorg.qol.todo-items.todo.task-pending)",   { desc = "neorg: set task to pending",   buffer = true })
vim.keymap.set("n", "<localleader>tu", "<Plug>(neorg.qol.todo-items.todo.task-recurring)", { desc = "neorg: set task to recurring", buffer = true })
vim.keymap.set("n", "<localleader>tu", "<Plug>(neorg.qol.todo-items.todo.task-undone)",    { desc = "neorg: set task to undone",    buffer = true })

vim.keymap.set("n", "<leader>tc", function()
  local cc = "nc"
  if vim.wo.concealcursor == cc then
    cc = ""
  end
  vim.wo.concealcursor = cc
end, { desc = "toggle concealcursor", buffer = true })

-- vim.keymap.set("n", "<localleader>", "<Plug>(neorg.)", { desc = "neorg: ", buffer = true })
-- vim.keymap.set("n", "", "<Plug>(neorg.)", { desc = "neorg: ", buffer = true })
