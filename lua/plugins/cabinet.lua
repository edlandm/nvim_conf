return {
  "smilhey/cabinet.nvim",
  lazy = false,
  config = function()
    local cabinet = require("cabinet")
    cabinet:setup({
      initial_drawers = { "neovim_config" },
    })

    -- Switch to drawer on creation
    vim.api.nvim_create_autocmd("User", {
      nested = true,
      pattern = "DrawAdd",
      callback = function(event)
        -- This is the name of the new drawer
        local new_drawer_name = event.data
        cabinet.drawer_select(new_drawer_name)
      end,
    })

    -- Open a terminal when entering a new drawer
    -- vim.api.nvim_create_autocmd("User", {
    -- 	nested = true,
    -- 	pattern = "DrawNewEnter",
    -- 	callback = function(event)
    -- 		vim.cmd("term")
    -- 	end,
    -- })

    local print_cur_drawer = function()
      vim.cmd.echo('"Drawer: '..cabinet.drawer_current()..'"')
    end

    local print_only_one_drawer = function()
      vim.cmd.echo('"Cabinet: only one drawer"')
    end

    local drawer_selector = function(prompt, callback)
      return function()
        local drawers = cabinet.drawer_list()
        if #drawers == 0 then
          vim.cmd.echo('"Cabinet: no drawers"')
          return
        end
        if #drawers == 1 and drawers[1] == cabinet.drawer_current() then
          print_only_one_drawer()
          return
        end
        vim.ui.select(drawers, {
          prompt = prompt..": ",
        }, function(choice)
            if not choice then return end
            vim.cmd.redraw()
            callback(choice)
          end)
      end
    end

    local open_drawer = function(drawer_name)
      cabinet.drawer_select(drawer_name)
      print_cur_drawer()
    end

    local delete_drawer = function(drawer_name)
      cabinet.drawer_delete(drawer_name)
      vim.cmd.echo('"Deleted Drawer: '..drawer_name..'"')
    end

    local move_cur_buf_to_drawer = function(drawer_name)
      vim.cmd({ cmd = "DrawerBufMove", args = { drawer_name } })
      vim.cmd.echo('"Buffer moved to: '..drawer_name..'"')
    end

    -- navigate vertically between drawers (starting from the "top") with j/k
    vim.keymap.set("n", "<leader>dk", function()
      local drawers = cabinet.drawer_list()
      if #drawers == 0 then
        vim.cmd.echo('"Cabinet: no drawers"')
        return
      end
      if #drawers == 1 and drawers[1] == cabinet.drawer_current() then
        print_only_one_drawer()
        return
      end
      cabinet.drawer_previous()
      print_cur_drawer()
    end, { desc = "Switch to Previous Drawer" })
    vim.keymap.set("n", "<leader>dj", function()
      local drawers = cabinet.drawer_list()
      if #drawers == 0 then
        vim.cmd.echo('"Cabinet: no drawers"')
        return
      end
      if #drawers == 1 and drawers[1] == cabinet.drawer_current() then
        print_only_one_drawer()
        return
      end
      cabinet.drawer_next()
      print_cur_drawer()
    end, { desc = "Switch to Next Drawer" })

    vim.keymap.set("n", "<leader>dc", ":DrawerNew ",
      { desc = "Create New Drawer" })
    vim.keymap.set("n", "<leader>dr", ":DrawerRename ",
      { desc = "Rename Current Drawer" })

    vim.keymap.set("n", "<leader>dd", print_cur_drawer,
      { desc = "Echo Current Drawer" })
    vim.keymap.set("n", "<leader>dl", "<cmd>DrawerList<cr>",
      { desc = "List Drawers" })
    vim.keymap.set("n", "<leader>db", "<cmd>DrawerListBuffers<cr>",
      { desc = "List Buffers in Current Drawer" })

    -- select a drawer and perform an action
    vim.keymap.set("n", "<leader>dx",
      drawer_selector("Select a drawer to delete", delete_drawer),
      { desc = "Delete Drawer" })
    vim.keymap.set("n", "<leader>dm",
      drawer_selector("Move current buffer to: ", move_cur_buf_to_drawer),
      { desc = "Move Current Buffer to a Drawer" })
    vim.keymap.set("n", "<leader>do",
      drawer_selector("Select a drawer to open", open_drawer),
      { desc = "Open Drawer" })
  end,
}
