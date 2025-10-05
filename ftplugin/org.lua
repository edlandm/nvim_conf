vim.wo.conceallevel = 2
vim.wo.wrap = false
vim.wo.concealcursor = 'nc'

local function select_code_block_contents()
  local ts = vim.treesitter
  local parser = ts.get_parser(0, "org")
  local root = parser:parse()[1]:root()

  -- Walk up the tree to find if we're inside a code block
  local current = root:named_descendant_for_range(
    vim.api.nvim_win_get_cursor(0)[1] - 1,
    0,
    vim.api.nvim_win_get_cursor(0)[1] - 1,
    0)

  local code
  while current do
    if current:type() == "block" then
      local contents = (current:field("contents") or {})[1]
      if contents and contents:child_count() > 0 then
        code = contents
        break
      end
    end
    current = current:parent()
  end

  if not code then
    vim.notify("Cursor is not inside a code block", vim.log.levels.INFO, {})
    return
  end

  local content_start_row = code:start()
  local content_end_row = code:end_()

  local cur_lnum = vim.fn.line('.') - 1
  local is_cursor_inside_contents = content_start_row < content_end_row
    and cur_lnum >= content_start_row - 1
    and cur_lnum <= content_end_row

  if is_cursor_inside_contents then
    local start_line = content_start_row + 1
    local end_line = content_end_row
    vim.api.nvim_win_set_cursor(0, {start_line, 0})
    vim.cmd("normal! V" .. (end_line - start_line) .. "jo")
    return
  end
end

---- MAPPINGS ================================================================
local mappings = require 'config.mappings'
local lleader = mappings.lleader
mappings.map {
  { mode = 'n', buffer = true,
    { 'ORG: CD to :PWD:', lleader '.', org.fn.cd_to_pwd },
    { 'Turn selection into a link to <clipboard>', lleader 'l', org.fn.selection_to_link },
    { 'Add New Heading after current section', '<m-l>', org.fn.insert_new_section },
    { 'New Subheading after current section',  '<m-d>', function() org.fn.insert_new_section({ is_subsection = true }) end },
    { 'Org: expand link to file path and open', 'gf',
      function()
        local path = org.fn.expand_link_path()
        if not path then return end
          vim.cmd { cmd = 'edit', args = { path } }
      end
    },
    { 'Org: expand link to file path and open (vsplit)', '<c-w><c-v>',
      function()
        local path = org.fn.expand_link_path()
        if not path then return end
          vim.cmd { cmd = 'vsplit', args = { path } }
      end
    },
    { 'Pick: Headlines', 'gs', org.pickers.headlines },
    { 'Select Codeblock Content', '<leader>v', select_code_block_contents },
    { '', '', '' },
  },
  { mode = 'i', buffer = true,
    { 'Add New Heading after current section', '<m-l>', org.fn.insert_new_section },
    { 'New Subheading after current section',  '<m-d>', function() org.fn.insert_new_section({ is_subsection = true }) end },
    { 'Insert Code Block',  '```', '#+BEGIN_SRC o#+END_SRC<Up>$' },
    { 'Insert Block Quote', '>> ', '#+BEGIN_QUOTE o#+END_QUOTE<Up>$' },
    { '', '', '' },
  },
  { mode = 'x', buffer = true,
    { 'Turn selection into a link to <clipboard>', lleader 'l', org.fn.selection_to_link },
    { '', '', '' },
  },
}

---- COMMANDS ================================================================
vim.api.nvim_buf_create_user_command(0, 'OrgLinkToPWD', org.fn.link_to_pwd, {
  desc = 'Link file to :PWD:/index.org',
})

vim.api.nvim_buf_create_user_command(0, 'OrgSelectCodeBlockContents',
  select_code_block_contents, {
    desc = 'Selects the contents of the current Org mode code block',
  }
)
