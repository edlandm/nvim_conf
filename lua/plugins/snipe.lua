local function open_buffer_delete_menu()
  -- selecting an entry will delete that buffer along with all of the buffers
  -- below/after it
  require("snipe").create_menu_toggler(
    function() return require("snipe").buffer_producer() end,
    function(bufnr, _)
      local bufnrs, _ = require("snipe").buffer_producer()
      for _, b in ipairs(bufnrs) do
        if (b >= bufnr) then
          vim.api.nvim_buf_delete(b, { force = false, unload = false })
        end
      end
    end)()
end

return {
  "leath-dub/snipe.nvim",
  events = "VeryLazy",
  opts = {
    ui = {
      max_width = -1, -- -1 means dynamic width
      -- Where to place the ui window
      -- Can be any of "topleft", "bottomleft", "topright", "bottomright", "center", "cursor" (sets under the current cursor pos)
      position = "center",
    },
    hints = {
      -- Charaters to use for hints (NOTE: make sure they don't collide with the navigation keymaps)
      dictionary = "htsnldaeicuowyvb",
    },
    navigate = {
      -- When the list is too long it is split into pages
      -- `[next|prev]_page` options allow you to navigate
      -- this list
      next_page = "<c-n>",
      prev_page = "<c-p>",

      -- You can also just use normal navigation to go to the item you want
      -- this option just sets the keybind for selecting the item under the
      -- cursor
      under_cursor = "<cr>",

      -- In case you changed your mind, provide a keybind that lets you
      -- cancel the snipe and close the window.
      cancel_snipe = "<esc>",
    },
  },
  keys = {
    {"<tab>b", function () require("snipe").open_buffer_menu({max_path_width = 3}) end, desc = "Snipe buffer menu"},
    {"<tab>x", open_buffer_delete_menu, desc = "Snipe buffer delete menu"},
  },
}
