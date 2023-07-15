set fdm=indent
set tabstop=2
set shiftwidth=2
autocmd FileType javascript setl omnifunc=xmlcomplete#CompleteTags

" Add semicolon to the end of the line
nnoremap <buffer> <leader>; A;<esc>
" Add comma to the end of the line
nnoremap <buffer> <leader>,, A,<esc>
inoremap <buffer> ;{ {}O

source ~/.vim/ftplugin/PLUGINS/console_mappings.vim
source ~/.vim/ftplugin/PLUGINS/clean_javascript_dicts.vim
