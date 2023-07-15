setlocal foldmethod=indent
setlocal foldminlines=1
setlocal foldlevel=0
setlocal foldlevelstart=0
" setlocal fdm=syntax
source ~/.vim/ftplugin/PLUGINS/shorthand.vim
let maplocalleader=','

function! Foldtext()
  " return (1 + v:foldend - v:foldstart) . ': ' . getline(v:foldstart)
  let l:text = system(': "' . getline(v:foldstart) . "\"; printf '%s' " . '"${_# *}"')
  return (1 + v:foldend - v:foldstart) . ':' . l:text
endfunction
setlocal foldtext=Foldtext()

function! FZF_Shorthand()
    let l:source = "awk '{ print $4 \\\" \\\" $3 }' ~/.vim/ftplugin/PLUGINS/shorthand.vim|sort|column -t"
    " let l:fzf_opts = '"sink": ".!printf '."'".'\\%s'."'".'", "left": "25%"'
    let l:fzf_opts = '"sink": ".!awk '."'".'{ print $1 }'."'".' <<<", "left": "25%"'

    normal o
    execute 'call fzf#run({' l:fzf_opts ', "source": "' l:source '"})'
    normal kJ
endfunction

" insert current timestamp (I know 'T' is a bad mneumonic for 'Date"; think 'Tag')
inoremap <buffer> T>  =strftime("%Y%m%d.%H:%M")<cr>
" create new todo-list entry (Add or Agendum)
nmap <buffer> <leader>a ggO+T><bar><bar><left>
" mark item as complete
nnoremap <buffer> <leader>A ^r=:silent! keeppatterns call search('^\S', 'W')<cr>
vnoremap <buffer> <leader>A :g/^\S/norm r=<cr>

" {{{ Renew agenda item: update timestamp, mark as important (!), move to top
function! AgendaRenewItem()
    let l:cur_line = line('.')
    let l:mch_line = search('^\S', 'nW')
    if l:mch_line == 0
        let l:mch_line = line('$')
    else
        let l:mch_line -= 1
    endif

    execute l:cur_line ',' l:mch_line 'm0'
    execute '1normal r!lct|T>0'
endfunction " }}}

nmap <buffer> <leader>R :call AgendaRenewItem()<cr>

" jump to next/prev agenda item
let s:agenda_item_regex = '^[+=]\d\_.\{-}\ze\n\([+=]\|ARCHIVE \)'
nnoremap <silent> <buffer> ] :silent! keeppatterns call search('^[+=]\d\_.\{-}\ze\n\([+=]\<bar>ARCHIVE \)', 'sW')<cr>
nnoremap <silent> <buffer> [ :silent! keeppatterns call search('^[+=]\d\_.\{-}\ze\n\([+=]\<bar>ARCHIVE \)', 'bsW')<cr>

nnoremap <buffer> <localleader>s :call FZF_Shorthand()<cr>

syn region AgendumDetails fold start=/^\s/rs=e end=/.\n\S/me=e-3
syn match ArchiveTitle /^ARCHIVE ----/me=e-5 contained
syn match ArchiveTimestamp /^\d\{8\}\.\d\{2\}:\d\{2\}/ contained
" " syn region Archive fold contains=ALL start=/^ARCHIVE -\+$/ end=/^-\+$/
syn region Archive fold contains=ArchiveTitle,ArchiveTimestamp
    \ start=/^ARCHIVE -\+$/
    \ end=/^-\+$/

hi Archive ctermfg=8 guifg=#6C768A
hi AgendumDetails ctermfg=8 guifg=#90A0B0
