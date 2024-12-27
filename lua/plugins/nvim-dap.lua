return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "rcarriga/nvim-dap-ui",
    "rcarriga/nvim-dap-ui",
    "debugloop/layers.nvim",
  },
  lazy = false,
  config = function()
    local dap, dapui = require("dap"), require("dapui")
    local layers = require('layers')
    dapui.setup()

    local DEBUG_MODE = layers.mode.new()
    DEBUG_MODE:auto_show_help()

    DEBUG_MODE:keymaps({
      n = {
        {
          '<leader>D', function()
            dap.disconnect()
          end, { desc = 'Close debugger' }
        },
        {
          '<F1>', function ()
            dap.step_back()
          end, { desc = 'Step Back' }
        },
        {
          '<F2>', function ()
            dap.step_out()
          end, { desc = 'Step Out' }
        },
        {
          '<F3>', function ()
            dap.step_over()
          end, { desc = 'Step Over' }
        },
        {
          '<F4>', function ()
            dap.step_into()
          end, { desc = 'Step Into' }
        },
        {
          '<F5>', function ()
            dap.continue()
          end, { desc = 'Play/Continue' }
        },
        {
          '<F6>', function ()
            dap.run_to_cursor()
          end, { desc = 'Run until cursor' }
        },
        {
          '<c-space>', function ()
            dap.toggle_breakpoint()
          end, { desc = 'Toggle Breakpoint' }
        },
        {
          'K',
          function () require("dap.ui.widgets").hover() end,
          { desc = 'Hover/Inspect' }
        },
      },
    })

    -- open and close debugger windows automatically based on evens
    dap.listeners.after.launch.dapui_config = function()
      dapui.open()
      DEBUG_MODE:activate()
    end
    dap.listeners.after.event_terminated.dapui_config = function()
      dapui.close()
      DEBUG_MODE:deactivate()
    end

    dap.defaults.fallback = {
      switchbuf = 'usevisible,usetab,uselast'
    }

    do -- configure bash
      dap.adapters.bashdb = {
        type = 'executable';
        command = vim.fn.stdpath("data") .. '/mason/packages/bash-debug-adapter/bash-debug-adapter';
        name = 'bashdb';
      }
      dap.configurations.sh = {
        {
          type = 'bashdb';
          request = 'launch';
          name = "Launch file";
          pathBashdb = vim.fn.stdpath("data") .. '/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb';
          pathBashdbLib = vim.fn.stdpath("data") .. '/mason/packages/bash-debug-adapter/extension/bashdb_dir';
          file = "${file}";
          program = "${file}";
          cwd = '${workspaceFolder}';
          pathCat = "cat";
          pathBash = "/bin/bash";
          pathMkfifo = "mkfifo";
          pathPkill = "pkill";
          args = {};
          argsString = "";
          env = {};
          terminalKind = "integrated";
          -- showDebugOutput = true;
          -- trace = true;
        }
      }
    end

    do -- configure csharp
      ---build the given c# project (Development configuration)
      ---@param project_file string path to .csproj file
      ---@return integer status code (0 = success)
      local function dotnet_build_project(project_file)
        assert(project_file, 'project_file required')
        local cmd = 'dotnet build -c Development ' .. project_file .. ' > /dev/null'
        local _, _, status = os.execute(cmd)
        return status or 0
      end

      ---find csproj file in _dir (default '.'); prompt user to select if
      ---multiple found
      ---error if none found or selection cancelled
      ---@param _dir string?
      ---@return string path to .csproj file
      local function dotnet_select_project(_dir)
        local dir = _dir or vim.fn.getcwd()
        local stdout = vim.fn.system('find '..dir..' -type f -name \\*.csproj')
        local lines = vim.split(vim.trim(stdout), '\n', { trimempty = true })
        assert(#lines > 0, 'no csproj files found in: '..dir)
        if #lines == 1 then
          return lines[1]
        end
        local choice = vim.fn.confirm('Select Project:', table.concat(lines, '\n'), 0)
        assert(choice > 0, 'Project not selected')
        return lines[choice]
      end

      ---prompt for a dll in the current directory and return the filepath
      ---@param project string path to csproj file
      ---@return string|dap.Abort|thread path to dll
      local function dotnet_select_dll(project)
        local dir, csproj = project:match('^%s*(.+)/([^/]+)$')
        assert(dir and csproj, 'unable to parse project path: '..project)

        local name = csproj:match('^(.-)%.csproj$')
        assert(name, 'invalid csproj file: '..csproj)

        local file = require('dap.utils').pick_file({
          path = dir,
          filter = name..'%.dll',
          executables = false,
        })
        assert(file, 'No file selected')
        return file
      end

      dap.adapters.coreclr = {
        type = 'executable',
        command = vim.fn.stdpath("data") .. '/mason/packages/netcoredbg/netcoredbg',
        args = { '--interpreter=vscode' },
      }
      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "launch - netcoredbg",
          request = "launch",
          -- TODO: learn how to use .vscode/launch.json file to set cwd from
          -- there
          cwd = "${workspaceFolder}/Generated",
          program = function ()
            ---@type string
            local csproj
            local dll_file
            if not vim.g.dotnet_last_dll then
              csproj = dotnet_select_project()
              dll_file = dotnet_select_dll(csproj)
            else
              local change = vim.fn.confirm(
                'Change target?\n' .. vim.g.dotnet_last_dll,
                '&yes\n&no',
                2)
              if change == 1 then
                csproj = dotnet_select_project()
                dll_file = dotnet_select_dll(csproj)
              end
            end

            if csproj and dll_file then
              vim.g.dotnet_last_csproj = csproj
              vim.g.dotnet_last_dll = dll_file
            end

            if vim.fn.confirm('Recompile first?', '&yes\n&no', 2) == 1 then
              local status = dotnet_build_project(vim.g.dotnet_last_csproj)
              if status > 0 then
                error('Build: Failed (code: ' .. status .. ')')
              end
              print('\nBuild: Succeeded ')
            end

            return vim.g.dotnet_last_dll
          end,
        },
      }
    end
  end,
}
