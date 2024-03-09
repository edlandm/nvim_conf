return {
  "tpope/vim-dadbod",
  ft = "sql",
  cmd = "DB",
  install = function()
    vim.cmd("helptags ~/.local/share/nvim/lazy/vim-dadbod/doc/")
  end,
  config = function()
    local function db_operator(start, _end)
      local s
      local e
      if (start < _end) then
        s = start
        e = _end
      else
        s = _end
        e = start
      end
      vim.cmd(s .. "," .. e .. "DB g:db")
    end

    local map = function(desc, opts) -- shorthand for adding the description
      local _t = {buffer = true, noremap = true, desc = desc}
      if opts then
        for k,v in pairs(opts) do
          _t[k] = v
        end
      end
      return _t
    end

    vim.keymap.set("n", "<localleader>e", function() _G.operator(db_operator) end,
      map("motion: execute SQL in current database"))
    vim.keymap.set("n", "<localleader>E", "<cmd>%DB<cr>",
      map("execute SQL in current database(entire buffer)"))
    vim.keymap.set("v", "<localleader>e", ":DB<cr>",
      map("execute SQL in current database "))

    vim.keymap.set("n", "<localleader>el", "<cmd>exe \"DB list '\" .. expand(\"<cword>\") .. \"'\"<cr>",
      map("SQL: list table under cursor"))

    vim.keymap.set("n", "<localleader>es", function()
      local tbl = vim.fn.expand("<cword>")
      if not tbl then return end
      local where = vim.fn.input("WHERE: ")
      if not where then return end
      vim.cmd("DB SELECT * FROM " .. tbl .. " WHERE " .. where .. ";")
    end, map("SQL: select from table under cursor using prompted `WHERE` clause"))

    vim.keymap.set("n", "<localleader>eS", function()
      local tbl = vim.fn.expand("<cword>")
      if not tbl then return end
      local count = vim.fn.input("COUNT: ")
      if not count or not tonumber(count) then return end
      vim.cmd("DB SELECT TOP " .. count .. " * FROM " .. tbl .. ";")
    end, map("SQL: select sample top `count` records of table under cursor"))

    vim.keymap.set("n", "<localleader>ef", function()
      local tbl = vim.fn.expand("<cword>")
      if not tbl then return end
      local field = vim.fn.input("Field: ")
      if not field then return end
      vim.cmd("DB SELECT " .. field .. " FROM " .. tbl .. "GROUP BY " .. field .. ";")
      end, map("SQL: get all unique values of `field` in table under cursor"))

    vim.keymap.set("n", "<localleader>dc", function()
      local connection = vim.g.db
      if not connection then print("Not currently connected to a database") return end
      -- get everything between the @ and the ?
      local server,db = connection:match("[^@]+@([^/?]+)/([^?]+)%?.*")
      print("Connected to: " .. server .. "." .. db)
    end, { buffer = true, desc = "Print current [d]atabase [c]onnection" })
  end,
}
