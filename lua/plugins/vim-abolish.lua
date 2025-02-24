
-- find, sub, and abbreviate variations of words
return {
  'tpope/vim-abolish',
  event = 'VeryLazy',
  init = function ()
    -- I decided to use gregorias/coerce.nvim for the coerce functionality
    vim.g.abolish_no_mappings = true
  end,
  config = function()
    ---define a list of abolish abbreviations/corrections all at once
    ---@param _pairs [string, string][]
    local function abolish(_pairs)
      for _, pair in ipairs(_pairs) do
        vim.cmd({ cmd = "Abolish", args = { pair[1], pair[2] } })
      end
    end

    abolish({
      { 'deploymenst', 'deployments' },
      { 'alais{,es}',  'alias{,es}'  },
      { 'dafeult{,s}', 'default{,s}' },
      { 'mappig{,s}',  'mapping{,s}' },
    })

    --[[
    --this is my own command that uses T-Pope's "Subvert" command
    --it's expected to be used on a range of lines that looks like this (in
    --between the lines that are all dashes)
    --------------------
    foo
    bar
    --%%
    let %s = "%S"
    --------------------
    --this will be expanded to output like this:
    --------------------
    let foo = "FOO"
    ====================
    --there is an additional awk-mode that works like this:
    --------------------
    foo bar
    baz buz
    --%a
    let $1 = "$2"
    --------------------
    --this will be expanded to output like this:
    --------------------
    let foo = "bar"
    let baz = "buz"
    --------------------
    --]]
    vim.api.nvim_create_user_command('Supplant',
      function(opts)
        local s, e = opts.line1, opts.line2
        local selection = vim.api.nvim_buf_get_lines(0, s-1, e, true)
        local lines = {}
        local template_lines = {}
        local mode

        -- line
        -- --(%%|awk)
        -- template
        for _, line in ipairs(selection) do
          if mode == nil then
            local m = line:match('--%%([%%as])')
            if m then
              if m == 'a' then
                mode = 'awk'
              else
                mode = 'subvert'
              end
            else
              table.insert(lines, line)
            end
          else
            table.insert(template_lines, line)
          end
        end

        assert(#lines > 0, 'no lines to apply to template')
        assert(#template_lines > 0, 'unable to parse template')
        assert(mode, 'unable to determine template mode')

        if mode == 'awk' then
          local tls = vim.tbl_map(function(line)
            local l = string.gsub(line, '"', '\\"')
            return string.gsub(l, '%$%d', '" %0 "')
          end, template_lines)
          local awk_cmd = ('{ print "%s"; }'):format(table.concat(tls, ''))
          local cmd = ("awk '%s'"):format(awk_cmd)
          local output = vim.fn.system(cmd, lines)
          -- dd({
          --   awk_cmd=awk_cmd,
          --   cmd=cmd,
          --   output=output,
          --   tls=tls,
          -- })
          vim.api.nvim_buf_set_lines(0, s-1, e, true, vim.split(output, '\n', {trimempty=true}))
          return
        end

        -- replace (s,e) range with one instance of template per line in `lines`
        -- for each instance of template, call :Subvert on it
        -- NOTE: an instance of a template may span multiple lines
        local placeholder_lines = {}
        for _, _ in ipairs(lines) do
          for _, tl in ipairs(template_lines) do
            table.insert(placeholder_lines, tl)
          end
        end

        vim.api.nvim_buf_set_lines(0, s-1, e, true, placeholder_lines)

        for i, line in ipairs(lines) do
          local _s = s + (#template_lines * (i-1))
          local _e = s + (#template_lines * (i-1)) + (#template_lines-1)
          local cmd = ('%s,%sSubvert/%%s/%s/g'):format(_s, _e, line)
          vim.cmd(cmd)
        end
      end, {
        desc = 'replace lines with an application of the template',
        range = true,
      }
    )
  end,
  keys = {
    { '<leader>S', ':Supplant<cr>', mode = { 'x' }, desc = 'Supplant with Template' }
  },
}
