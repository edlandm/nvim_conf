---function to that returns function that applies `opts` to the given flash method
---@param method string
---@param opts? table
---@return function
local function flash(method, opts)
  assert(method, 'method required')
  return function()
    local f = require('flash')
    assert(f, 'unable to load flash')
    f[method](opts)
  end
end

return {
  "folke/flash.nvim",
  event = "VeryLazy",
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
      },
      char_actions = function(motion)
        return {
          -- jump2d style: same case goes next, opposite case goes prev
          [motion] = "next",
          [motion:match("%l") and motion:upper() or motion:lower()] = "prev",
        }
      end,
      jump = { autojump = true }
    },
  },
  keys = {
    { "_j", flash('jump', {
      search = { forward = true, multi_window = true, wrap = false, }
    }), mode = {"n", "x", "o" }, desc = "flash: jump forward (down)" },
    { "_k", flash('jump', {
      search = { forward = false, multi_window = true, wrap = false, }
    }), mode = {"n", "x", "o" }, desc = "flash: jump backward (up)" },
    { "_*", flash('jump', {
      pattern = vim.fn.expand("<cword>"),
      search = {
        mode = function(pattern)
          return ([[\<%s\>]]):format(pattern)
        end,
      },
    }), mode = {"n", "x", "o" }, desc = "flash: cword" },
    { "_d", flash('jump', {
      matcher = function(win)
        return vim.tbl_map(function(diag)
          return {
            pos = { diag.lnum + 1, diag.col },
            end_pos = { diag.end_lnum + 1, diag.end_col - 1 },
          }
        end, vim.diagnostic.get(vim.api.nvim_win_get_buf(win)))
      end,
      action = function(match, state)
        vim.api.nvim_win_call(match.win, function()
          vim.api.nvim_win_set_cursor(match.win, match.pos)
          vim.diagnostic.open_float()
        end)
        state:restore()
      end,
    }), mode = "n", desc = 'flash: show diagnostics at target' },
    { "__",    flash('jump', { continue = true }), mode = { "n", "x", "o" }, desc = "flash: continue searc" },
    { "_",     flash 'remote',            mode = "o",               desc = "flash: remote" },
    { "<cr>",  flash 'treesitter',        mode = { "n", "x", "o" }, desc = "flash: Treesitter mode" },
    { "<c-s>", flash 'treesitter_search', mode = { "n", "x", "o" }, desc = "flash: Treesitter search" },
    { "<c-s>", flash("toggle"),           mode = "c",               desc = "Toggle Flash Search" },
  }
}
