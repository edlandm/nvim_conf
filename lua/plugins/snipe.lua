local function set_mappings(default_config)
  local mappings = require('mappings')
  local snipe = require('snipe')
  local menu = require('snipe.menu'):new(default_config)

  menu:add_new_buffer_callback(snipe.default_keymaps)

  local function list_buffers()
    local items = require('snipe.buffer').get_buffers()
    menu.config.open_win_override.title = 'Snipe [Open]'
    menu:open(items, function(m, i)
      m:close()
      vim.api.nvim_set_current_buf(m.items[i].id)
    end, function (item) return item.name end)
  end

  local function delete_buffers()
    local items = require('snipe.buffer').get_buffers()
    menu.config.open_win_override.title = 'Snipe [Delete]'
    menu:open(items, function(m, i)
      local bufnr = m.items[i].id
      -- I have to hack switch back to main window, otherwise currently background focused
      -- window cannot be deleted when focused on a floating window
      local current_tabpage = vim.api.nvim_get_current_tabpage()
      local root_win = vim.api.nvim_tabpage_list_wins(current_tabpage)[1]
      vim.api.nvim_set_current_win(root_win)
      vim.api.nvim_buf_delete(bufnr, { force = true })
      vim.api.nvim_set_current_win(m.win)
      table.remove(m.items, i)
      m:reopen()
    end, function (item) return item.name end)
  end

  mappings.nmap({
    { 'Snipe: List buffers',   '<tab>b', list_buffers },
    { 'Snipe: Delete buffers', '<tab>x', delete_buffers },
  })
end

return {
  'leath-dub/snipe.nvim',
  lazy = false,
  opts = {
    ui = {
      max_width = -1, -- -1 means dynamic width
      -- Where to place the ui window
      -- Can be any of "topleft", "bottomleft", "topright", "bottomright", "center", "cursor" (sets under the current cursor pos)
      position = "center",
    },
    hints = {
      -- Characters to use for hints (NOTE: make sure they don't collide with the navigation keymaps)
      dictionary = "htsnaeiclduowyvb",
    },
    navigate = {
      -- When the list is too long it is split into pages
      -- `[next|prev]_page` options allow you to navigate
      -- this list
      next_page = "]",
      prev_page = "[",
      -- You can also just use normal navigation to go to the item you want
      -- this option just sets the keybind for selecting the item under the
      -- cursor
      under_cursor = "<cr>",
      -- In case you changed your mind, provide a keybind that lets you
      -- cancel the snipe and close the window.
      cancel_snipe = "<esc>",
      -- Open buffer in vertical split
      open_vsplit = "V",
      -- Open buffer in split, based on `vim.opt.splitbelow`
      open_split = "S",
      -- Close the buffer under the cursor
      -- Remove "j" and "k" from your dictionary to navigate easier to delete
      -- NOTE: Make sure you don't use the character below on your dictionary
      close_buffer = "D",
    },
  },
  config = function(conf)
    local opts = conf.opts
    local snipe = require('snipe')
    snipe.setup(conf)

    local default_config = {
      dictionary = opts.hints.dictionary,
      position = opts.ui.position,
      navigate = opts.navigate,
    }

    snipe.ui_select_menu = require("snipe.menu"):new(default_config)
    snipe.ui_select_menu:add_new_buffer_callback(function (m)
      vim.keymap.set("n", "<esc>", function ()
        m:close()
      end, { nowait = true, buffer = m.buf })
    end)
    vim.ui.select = snipe.ui_select;

    set_mappings(default_config)
  end,
}
