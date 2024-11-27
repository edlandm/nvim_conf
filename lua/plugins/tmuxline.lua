return {
  'edkolev/tmuxline.vim',
	event = 'VeryLazy',
	cond = function ()
		if os.getenv('TMUX') then
			return true
		end
		return false
	end,
  cmd = {
    'Tmuxline',
    'TmuxlineSnapshot',
  }
}
