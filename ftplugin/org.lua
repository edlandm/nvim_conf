vim.wo.conceallevel = 2
vim.wo.wrap = false
vim.wo.concealcursor = 'nc'

---- MAPPINGS ================================================================
local mappings = require 'mappings'
mappings.nmap({
  { 'ORG: CD to :PWD:', '<localleader>.', org.fn.cd_to_pwd },
  { 'Turn selection into a link to <clipboard>', '<localleader>l', org.fn.selection_to_link },
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
  -- { 'DESC', 'LHS',  },
}, true)

mappings.imap({
  { 'Add New Heading after current section', '<m-l>', org.fn.insert_new_section },
  { 'New Subheading after current section',  '<m-d>', function() org.fn.insert_new_section({ is_subsection = true }) end },
  -- { 'DESC', 'LHS',  },
}, true)

mappings.xmap({
  { 'Turn selection into a link to <clipboard>', '<localleader>l', org.fn.selection_to_link },
  -- { 'DESC', 'LHS',  },
}, true)

---- COMMANDS ================================================================
vim.api.nvim_buf_create_user_command(0, 'OrgLinkToPWD', org.fn.link_to_pwd, {
  desc = 'Link file to :PWD:/index.org',
})
