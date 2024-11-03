local nmap = require('mappings').nmap
local leader = require('mappings').leader

nmap({
  {'Toggle Quickfix Window', '<c-c>', '<cmd>lua require("quicker").toggle()<cr>'},
  {'Toggle Quickfix Window', leader('co'), '<cmd>lua require("quicker").open()<cr>'},
})

return {
  'stevearc/quicker.nvim',
  event = "FileType qf",
  opts = {
    max_filename_width = function ()
      return math.floor(math.min(50, vim.o.columns / 2))
    end,
    keys = {
      {
        ">",
        function()
          require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
        end,
        desc = "Expand quickfix context",
      },
      {
        "<",
        function()
          require("quicker").collapse()
        end,
        desc = "Collapse quickfix context",
      },
      {
        "<cr>",
        function()
          local line = vim.fn.line('.')
          vim.cmd('cc ' .. line)
        end,
        desc = "Jump to selected line in quickfix list",
      },
    },
  },
}
