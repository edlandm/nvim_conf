return {
  'unphased/cabinet.nvim',
  lazy = false,
  dependencies = {
    'folke/snacks.nvim'
  },
  opts = {
    ---@diagnostic disable I know that stdpath returns a string here
    workspace_file = vim.fs.joinpath(vim.fn.stdpath('data'), 'workspaces.txt'),
  },
  config = function(_, opts)
    local cabinet = require("cabinet")
    cabinet.workspaces_file = opts.workspace_file
    function cabinet:get_workspaces()
      local path = self.workspaces_file
      assert(vim.fn.filereadable(path) == 1, ('file not readable: %s'):format(path))

      ---@type { [string]: path }
      local workspaces = {}
      local i = 0
      for line in io.lines(path) do
        i = i + 1
        if not (line:match('^#') or line:match('^%s*$')) then
          local s, e = line:find('%s+')
          assert(s and s > 1, ('parse error: line %d: %s\n'):format(i, line))

          local name = line:sub(1, s-1)
          local dir = line:sub(e+1)
          assert(not workspaces[name],
            ('duplicate workspace: %s on line %d'):format(name, i))

          ---@type path
          local _dir = vim.fn.expand(dir)
          assert(vim.fn.isdirectory(_dir) == 1,
            ('fs error line %d: directory not found: '):format(i, _dir))

          workspaces[name] = _dir
        end
      end

      return workspaces
    end

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

        local workspaces = cabinet:get_workspaces()
        local workspace = workspaces[drawer]
        if workspace then
          vim.cmd { cmd = 'cd', args = { workspace, } }

          local index_files = { 'index.org', 'index.norg', 'index.md' }
          local index_file
          for _, f in ipairs(index_files) do
            local path = vim.fs.joinpath(workspaces[drawer], f)
            local stat = vim.uv.fs_stat(path)
            if stat and stat.type == 'file' then
              index_file = path
              break
            end
          end

          if index_file then
            vim.cmd { cmd = 'edit', args = { index_file } }
          end
        end
      end,
    })

    ---@diagnostic disable
    local starting_file = vim.fn.argv(0)
    local starting_file_dir = vim.fs.dirname(vim.fs.abspath(starting_file))
    local starting_drawer
    local drawers = { 'scratch' }
    local workspaces = cabinet:get_workspaces()
    for _, name in ipairs(vim.tbl_keys(workspaces)) do
      table.insert(drawers, name)
      if not starting_drawer and starting_file ~= '' then
        if vim.fn.expand(workspaces[name]) == vim.fs.dirname(vim.fs.abspath(starting_file)) then
          starting_drawer = name
        end
      end
    end

    if not starting_drawer then
      starting_drawer = 'scratch'
    end

    -- ensure that the starting_drawer is the first one
    table.sort(drawers, function(a, b)
      if a == starting_drawer then
        return true
      elseif b == starting_drawer then
        return false
      end
      return a < b
    end)

    cabinet:setup({
      initial_drawers = drawers,
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

        local success, picker = pcall(require, 'snacks.picker')
        if not success then
          select(drawers, {
            prompt = prompt..": ",
          }, function(choice)
              if not choice then return end
              vim.cmd.redraw()
              callback(choice)
            end)
          return
        end

        Snacks.picker.pick {
          source = 'Cabinet Drawers',
          layout = 'select',
          title = prompt,
          actions = {
            edit = {
              action = function(self)
                assert(cabinet.workspaces_file, 'opts.workspaces_file not defined')
                self:close()
                vim.cmd({ cmd = 'edit', args = { cabinet.workspaces_file } })
                vim.api.nvim_create_autocmd('BufWritePost', {
                  desc = 'reload workspaces/drawers',
                  buffer = 0,
                  callback = function()
                    -- TODO
                    -- if any new drawers were added, we want to add them to
                    -- the drawer-list
                    print('Workspaces Updated')
                    return
                  end
                })
              end,
              desc = 'edit workspaces file',
            },
          },
          confirm = callback,
          items = vim.tbl_map(function(drawername)
            local drawer
            for _, _drawer in ipairs(cabinet.drawer_manager.drawers) do
              if _drawer.name == drawername then
                drawer = _drawer
                break
              end
            end
            assert(drawer, 'Unable to find drawer: ' .. drawername)

            local preview = '# ' .. drawername
            if #drawer.buffers > 0 then
              preview = preview .. table.concat(
                vim.tbl_map(vim.api.nvim_buf_get_name, drawer.buffers),
                '\n')
            end
            return {
              text = drawername,
              file = workspaces[drawername] or drawername,
              preview = { text = preview, ft = 'markdown' },
            }
          end, drawers),
          preview = 'preview',
          format = function (item) return { { item.text, 'SnacksPickerFile' } } end,
          win = {
            input = {
              keys = {
                ['<c-e>'] = { 'edit', mode = { 'i', 'n' } },
              },
            },
          },
        }
      end
    end

    local open_drawer = function(picker, item)
      picker:close()
      cabinet.drawer_select(item.text)
    end

    local delete_drawer = function(picker, item)
      picker:close()
      local drawer_name = item.text
      cabinet.drawer_delete(drawer_name)
      vim.cmd.echo('"Deleted Drawer: '..drawer_name..'"')
    end

    local move_cur_buf_to_drawer = function(picker, item)
      picker:close()
      local drawer_name = item.text
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
