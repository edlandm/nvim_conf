return {
  'unphased/cabinet.nvim',
  dependencies = {
    'nvim-neorg/neorg',
  },
  lazy = false,
  config = function()
    local cabinet = require("cabinet")
    local workspaces = { "home" }

    local neorg = require("neorg")
    if neorg then -- set up neorg workspace hook
      local dirman = neorg.modules.get_module("core.dirman")
      local neorg_workspaces = { }
      for _, workspace in ipairs(dirman.get_workspace_names()) do
        if workspace ~= "default" and workspace ~= "home" then
          table.insert(neorg_workspaces, workspace)
        end
      end

      table.sort(neorg_workspaces)

      for _, workspace in ipairs(neorg_workspaces) do
        table.insert(workspaces, workspace)
      end

      -- Open Neorg workspace when entering one of the initial drawers for the first time
      vim.api.nvim_create_autocmd("User", {
        nested = true,
        pattern = "DrawNewEnter",
        callback = function(event)
          local drawer = event.data[2]
          print('Drawer: ' .. drawer)

          local drawer_index
          for i,name in ipairs(cabinet.drawer_list()) do
            if name == drawer then
              drawer_index = i
              break
            end
          end

          assert(drawer_index, "Drawer not found in list")
          if #cabinet.drawer_list_buffers(drawer_index) > 1 then return end
          if not dirman.get_workspace(drawer) then return end
          dirman.open_workspace(drawer)
        end,
      })
    else
      workspaces[1] = "home"
    end

    cabinet:setup({
      initial_drawers = workspaces,
    })

    local save = require("cabinet.save")
    save.save_cmd()
    save.load_cmd()

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

        local select = vim.ui.select
        local minipick = package.loaded._G.MiniPick
        if minipick then
          -- TODO: add preview to list buffers in drawer
          -- (not sure if currently possible via cabinet's api)
          select = minipick.ui_select
        end

        select(drawers, {
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
    end

    local delete_drawer = function(drawer_name)
      cabinet.drawer_delete(drawer_name)
      vim.cmd.echo('"Deleted Drawer: '..drawer_name..'"')
    end

    local move_cur_buf_to_drawer = function(drawer_name)
      vim.cmd({ cmd = "DrawerBufMove", args = { drawer_name } })
      vim.cmd.echo('"Buffer moved to: '..drawer_name..'"')
    end

    local prefix = function(lhs) return "<leader><tab>" .. lhs end

    -- navigate vertically between drawers (starting from the "top") with j/k
    vim.keymap.set("n", prefix("k"), function()
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
    end, { desc = "Switch to Previous Drawer" })
    vim.keymap.set("n", prefix("j"), function()
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
    end, { desc = "Switch to Next Drawer" })

    vim.keymap.set("n", prefix("c"), ":DrawerNew ",
      { desc = "Create New Drawer" })

    vim.keymap.set("n", prefix("C"), function ()
      local input = vim.fn.input({prompt = 'Create Drawer: ', cancelreturn = ''})
      if vim.fn.empty(input) == 1 then return end
      local current = cabinet.drawer_current()
      vim.cmd({ cmd = "DrawerNew", args = { input } })
      cabinet.drawer_select(current)
      vim.cmd({ cmd = "DrawerBufMove", args = { input } })
      vim.cmd.edit("#")
      cabinet.drawer_select(input)
    end,
      { desc = "Create New Drawer with <cbuf>" })

    vim.keymap.set("n", prefix("r"), ":DrawerRename ",
      { desc = "Rename Current Drawer" })

    vim.keymap.set("n", prefix("."), function() print("Drawer: "..cabinet.drawer_current()) end,
      { desc = "Echo Current Drawer" })
    vim.keymap.set("n", prefix("l"), "<cmd>DrawerList<cr>",
      { desc = "List Drawers" })

    -- select a drawer and perform an action
    vim.keymap.set("n", prefix("x"),
      drawer_selector("Select a drawer to delete", delete_drawer),
      { desc = "Delete Drawer" })
    vim.keymap.set("n", prefix("m"),
      drawer_selector("Move current buffer to: ", move_cur_buf_to_drawer),
      { desc = "Move Current Buffer to a Drawer" })
    vim.keymap.set("n", prefix("o"),
      drawer_selector("Select a drawer to open", open_drawer),
      { desc = "Open Drawer" })
  end,
}
