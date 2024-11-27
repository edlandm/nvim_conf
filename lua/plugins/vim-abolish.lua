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
  end
}
