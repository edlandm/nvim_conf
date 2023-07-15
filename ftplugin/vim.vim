set fdm=marker shiftwidth=2 tabstop=2

" execute the current line in vim (great for testing a new mapping
nnoremap <buffer> <leader>e :exec getline(".") <bar> echo getline(".")<cr>
