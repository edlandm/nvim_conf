

return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
  },
  lazy = false,
  config = function()
    local dap, dapui = require("dap"), require("dapui")
    local api = vim.api
    dapui.setup()

    -- open and close debugger windows automatically based on evens
    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end

    do -- Map K to hover while session is active.
      local keymap_restore = {}
      dap.listeners.after['event_initialized']['me'] = function()
        for _, buf in pairs(api.nvim_list_bufs()) do
          local keymaps = api.nvim_buf_get_keymap(buf, 'n')
          for _, keymap in pairs(keymaps) do
            if keymap.lhs == "K" then
              table.insert(keymap_restore, keymap)
              api.nvim_buf_del_keymap(buf, 'n', 'K')
            end
          end
        end
        api.nvim_set_keymap(
          'n', 'K', '<cmd>lua require("dap.ui.widgets").hover()<cr>', { silent = true })
      end

      dap.listeners.after['event_terminated']['me'] = function()
        for _, keymap in pairs(keymap_restore) do
          api.nvim_buf_set_keymap(
            keymap.buffer,
            keymap.mode,
            keymap.lhs,
            keymap.rhs,
            { silent = keymap.silent == 1 }
          )
        end
        keymap_restore = {}
      end
    end

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
  end,
}
