setlocal conceallevel=2
setlocal concealcursor=nc
setlocal shiftwidth=2
setlocal tabstop=2
setlocal nowrap

augroup NORG_JOURNAL
  au!
  au FileReadPost */journal/*.norg 1s/DATE$/\=system("date +'%Y.%m.%d'|tr -d $'\n'")/e
augroup END
