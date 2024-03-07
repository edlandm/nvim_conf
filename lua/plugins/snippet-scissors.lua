return {
	'chrisgrieser/nvim-scissors',
	dependencies = {
    'L3MON4D3/LuaSnip'
  },
  config = true,
  keys = {
    { '<leader>Sc', function() require("scissors").addNewSnippet() end,
      mode = { 'n', 'v' },
      desc = 'Snippet Create' },
    { '<leader>Se', '<cmd>ScissorsEditSnippet<cr>', desc = 'Snippet Edit' },
  },
  cmd = {
    'ScissorsAddSnippet',
    'ScissorsEditSnippet',
  },
}
