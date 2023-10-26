local flash_jump = function(_forward)
  require("flash").jump({
    search = { forward = _forward, multi_window = true, wrap = false, },
  })
end

local select_any_word = function()
  require("flash").jump({
    pattern = ".", -- initialize pattern with any char
    search = {
      mode = function(pattern)
        -- remove leading dot
        if pattern:sub(1, 1) == "." then
          pattern = pattern:sub(2)
        end
        -- return word pattern and proper skip pattern
        return ([[\<%s\w*\>]]):format(pattern), ([[\<%s]]):format(pattern)
      end,
    },
    -- select the range
    jump = { pos = "range" },
  })
end

local flash_cword = function()
  require("flash").jump({
    pattern = vim.fn.expand("<cword>"),
    search = {
      mode = function(pattern)
        return ([[\<%s\>]]):format(pattern)
      end,
    },
  })
end

return {
  "folke/flash.nvim",
  event = "VimEnter",
  opts = {
    labels = "cieahtsnbyouldwvgxjkrmf",
    label = {
      rainbow = {
        enabled = true,
        -- number between 1 and 9
        shade = 5,
      },
    },
    modes = {
      char = {
        jump_labels = true,
      }
    }
  },
  config = true,
  keys = {
    { "_j",  "<cmd>lua require('flash').jump({ search = { forward = true, multi_window = true, wrap = false } })<cr>",
      mode = {"n", "x", "o" }, desc = "flash: jump forward (down)" },
    { "_k",  "<cmd>lua require('flash').jump({ search = { forward = false, multi_window = true, wrap = false } })<cr>",
      mode = {"n", "x", "o" }, desc = "flash: jump backward (up)" },
    { "_w", select_any_word, mode = {"n", "x", "o" }, desc = "flash: jump start of word" },
    { "_n", flash_cword, mode = {"n", "x", "o" },
        desc = "flash: initialize with cword" },
    { "_t", "<cmd>lua require('flash').treesitter()<cr>", mode = {"n", "x", "o"},
        desc = "flash: treesitter nodes" },
    { "__", "<cmd>lua require('flash').jump({continue = true})<cr>", mode = {"n", "x", "o"},
        desc = "flash: continue last jump" },
    { "r", "<cmd>lua require('flash').remote()<cr>", mode = "o",
        desc = "flash: remote" },
    { "R", "<cmd>lua require('flash').treesitter_search()<cr>", mode = "o",
        desc = "flash: Treesitter Search" },
  }
}
