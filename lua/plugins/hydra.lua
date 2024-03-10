return {
  "nvimtools/hydra.nvim",
  event = "UIEnter",
  config = function()
    local Hydra = require("hydra")
    local m = require("hydra.keymap-util")
    local cmd = m.cmd
    Hydra({
      name = "DEBUGGER MODE",
      mode = "n",
      body = "<leader>D",
      hint = [[DEBUGGER]],
      config = {
        color = "pink", -- allow non-specified keys to work like normal
        invoke_on_body = true, -- this makes hydra behave with which-key
        hint = {
          type = "window",
          position = "top",
        },
        on_enter = function()
          require("dapui").open()
        end,
      },
      heads = {
        { "<cr>",  cmd("lua require('dap').continue()"),  { desc = "Run" } },
        { "<c-t>", cmd("lua require('dap').toggle_breakpoint()"), { desc = "Break" } },
        { "<c-h>", cmd("lua require('dap').step_out()"),  { desc = "Step Out" } },
        { "<c-j>", cmd("lua require('dap').step_into()"), { desc = "Step Into" } },
        { "<c-k>", cmd("lua require('dap').step_over()"), { desc = "Step Over" } },
        { "<c-l>", cmd("lua require('dap').dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))"), { desc = "Log" } },
        { "<c-c>", cmd("lua require('dap').clear_breakpoints()"), { desc = "Clear" } },
        { "<c-r>", function ()
          local dap = require("dap")
          local session = dap.session()
          if not session then
            print("No active debug session")
            return
          end

          local argstr = vim.fn.input("Restart with args: ")
          if vim.fn.empty(argstr) == 1 then
            dap.run_last()
            return
          end

          local args = assert(
            -- this is a kind of jankey way of parsing a string into an array
            -- of command-line arguments, but I couldn't find a good built-in
            -- way to do so in neovim, so I opted to use bash to do the
            -- parsing.
            vim.split(
              vim.fn.system(
                "bash",
                "for arg in "..argstr
                ..";do printf '%s%s' \"$arg\" $'\\r\\n';done"
              ),
              -- In the future, this may need to be refined to use a different
              -- (rarer) separator.
              "\r\n"),
            "Failed to parse args")
          local config = vim.deepcopy(session.config)
          config.args = args
          dap.restart(config)
        end,  { desc = "Restart" } },
        { "<c-e>", function ()
          local dapui = require("dapui")
          local expr = vim.fn.input("Add expression to watch: ")
          if vim.fn.empty(expr) == 1 then return end
          dapui.elements.watches.add(expr)
        end, { desc = "Watch Expr" } },
        { "<c-p>", cmd("lua require('dap.ui.widgets').preview()"),  { desc = "Preview" } },
        { "<esc>", cmd('echo ""'), { desc = false, exit = true } },
        { "<c-x>", function()
          require('dap').disconnect()
          require("dapui").close()
        end,  { desc = "Disconnect", exit = true, } },
      },
    })
  end
}
