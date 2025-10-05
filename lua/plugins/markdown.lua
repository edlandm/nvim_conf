local mappings = require 'config.mappings'
local map = mappings.to_lazy
local ll = mappings.lleader

return {
  dir = vim.fs.joinpath(vim.fn.stdpath('config'), 'plugin', 'markdown.nvim'),
  ft = 'markdown',
  specs = {
    {
      -- live-preview markdown files in browser
      'iamcco/markdown-preview.nvim',
      build = ":call mkdp#util#install()",
      ft = { 'markdown' },
      keys = map { ft = 'markdown',
        { 'Markdown Preview', '<F3>', '<cmd>MarkdownPreviewToggle<cr>' },
      },
    },
    {
      'bngarren/checkmate.nvim',
      ft = { 'markdown' },
      opts = {
        files = {
          'todo{,.md}',
          'TODO{,.md}',
          'index.md',
          'mind/*.md',
          'mind/**/*.md'
        },
        keys = {
          ["<localleader>tt"] = {
            rhs = "<cmd>Checkmate toggle<CR>",
            desc = "Toggle todo item",
            modes = { "n", "v" },
          },
          ["<localleader>tc"] = {
            rhs = "<cmd>Checkmate check<CR>",
            desc = "Set todo item as checked (done)",
            modes = { "n", "v" },
          },
          ["<localleader>tu"] = {
            rhs = "<cmd>Checkmate uncheck<CR>",
            desc = "Set todo item as unchecked (not done)",
            modes = { "n", "v" },
          },
          --[[
          ["<localleader>t="] = {
            rhs = "<cmd>Checkmate cycle_next<CR>",
            desc = "Cycle todo item(s) to the next state",
            modes = { "n", "v" },
          },
          ["<localleader>t-"] = {
            rhs = "<cmd>Checkmate cycle_previous<CR>",
            desc = "Cycle todo item(s) to the previous state",
            modes = { "n", "v" },
          },
          --]]
          ["<localleader>tn"] = {
            rhs = "<cmd>Checkmate create<CR>",
            desc = "Create todo item",
            modes = { "n", "v" },
          },
          ["<localleader>tr"] = {
            rhs = "<cmd>Checkmate remove<CR>",
            desc = "Remove todo marker (convert to text)",
            modes = { "n", "v" },
          },
          ["<localleader>tR"] = {
            rhs = "<cmd>Checkmate remove_all_metadata<CR>",
            desc = "Remove all metadata from a todo item",
            modes = { "n", "v" },
          },
          ["<localleader>tA"] = {
            rhs = "<cmd>Checkmate archive<CR>",
            desc = "Archive checked/completed todo items (move to bottom section)",
            modes = { "n" },
          },
          ["<localleader>tv"] = {
            rhs = "<cmd>Checkmate metadata select_value<CR>",
            desc = "Update the value of a metadata tag under the cursor",
            modes = { "n" },
          },
          ["<localleader>t]"] = {
            rhs = "<cmd>Checkmate metadata jump_next<CR>",
            desc = "Move cursor to next metadata tag",
            modes = { "n" },
          },
          ["<localleader>t["] = {
            rhs = "<cmd>Checkmate metadata jump_previous<CR>",
            desc = "Move cursor to previous metadata tag",
            modes = { "n" },
          },
        },
        todo_states = {
          -- we don't need to set the `markdown` field for `unchecked` and `checked` as these can't be overriden
          unchecked = {
            marker = "[ ]",
            order = 1,
          },
          checked = {
            marker = "[x]",
            order = 3,
          },
          -- Custom states
          in_progress = {
            marker = "[/]",
            markdown = "/",     -- Saved as `- [.]`
            type = "incomplete", -- Counts as "not done"
            order = 2,
          },
          ambiguous = {
            marker = "[?]",
            markdown = "?",     -- Saved as `- [/]`
            type = "inactive",   -- Ignored in counts
            order = 5,
          },
          on_hold = {
            marker = "[!]",
            markdown = "!",     -- Saved as `- [/]`
            type = "incomplete",   -- Ignored in counts
            order = 99,
          },
          cancelled = {
            marker = "[-]",
            markdown = "-",     -- Saved as `- [c]`
            type = "complete",   -- Counts as "done"
            order = 100,
          },
        },
        todo_count_formatter = function(completed, total)
          local bar
          local remaining = total - completed
          if remaining < total and total > 4 then
            if remaining == 0 then
              bar = '✨ '
            else
              local percent = completed / total * 100
              local bar_length = 5
              local filled = math.floor(bar_length * percent / 100)
              bar = string.rep("~", filled) .. '->' .. string.rep(" ", bar_length - filled) .. remaining
            end
          end
          local progress = string.format("%d/%d %s", completed, total, bar or '')
          if #progress > 15 then -- don't exceed max-length
            progress = string.format("[%d/%d]", completed, total)
          end
          return progress
        end,
        metadata = {
          -- Example: A @priority tag that has dynamic color based on the priority value
          priority = {
            style = function(context)
              local value = context.value:lower()
              if value == "high" then
                return { fg = "#ff5555", bold = true }
              elseif value == "medium" then
                return { fg = "#ffb86c" }
              elseif value == "low" then
                return { fg = "#8be9fd" }
              else -- fallback
                return { fg = "#8be9fd" }
              end
            end,
            get_value = function()
              return "medium" -- Default priority
            end,
            choices = function()
              return { "low", "medium", "high" }
            end,
            key = "<localleader>tp",
            sort_order = 10,
            jump_to_on_insert = "value",
            select_on_insert = true,
          },
          -- Example: A @started tag that uses a default date/time string when added
          started = {
            aliases = { "init" },
            style = { fg = "#9fd6d5" },
            get_value = function()
              return tostring(os.date("%m/%d/%y %H:%M"))
            end,
            key = "<localleader>ts",
            sort_order = 20,
          },
          -- Example: A @done tag that also sets the todo item state when it is added and removed
          done = {
            aliases = { "completed", "finished" },
            style = { fg = "#96de7a" },
            get_value = function()
              return tostring(os.date("%m/%d/%y %H:%M"))
            end,
            key = "<localleader>td",
            on_add = function(todo_item)
              require("checkmate").set_todo_item(todo_item, "checked")
            end,
            on_remove = function(todo_item)
              require("checkmate").set_todo_item(todo_item, "unchecked")
            end,
            sort_order = 30,
          },
        },
      },
    },
  },
  opts = {
  },
  keys = map { ft = 'markdown',
    -- { 'Add List Item',    ll 'l',  '<Plug>(MarkdownAddListItem)' },
    { 'Add List Item',    ';n',    '<Plug>(MarkdownAddListItem)', mode = { 'i' } },
    -- { 'Append List Item', ll 'L',  '<Plug>(MarkdownAppendListItem)' },
    { 'Append List Item', ';N',    '<Plug>(MarkdownAppendListItem)', mode = { 'i' } },
    -- { 'Add Task',         ll 't', '<Plug>(MarkdownAddTask)' },
    { 'Add Task',         ';t',    '<Plug>(MarkdownAddTask)', mode = { 'i' } },
    -- { 'Append Task',      ll 'T', '<Plug>(MarkdownAppendTask)' },
    { 'Append Task',      ';T',    '<Plug>(MarkdownAppendTask)', mode = { 'i' } },
  },
}
