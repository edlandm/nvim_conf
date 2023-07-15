setlocal nocindent
setlocal wrap
setlocal linebreak
setlocal nolist
setlocal formatoptions+=1
setlocal shiftwidth=2
setlocal tabstop=2

function! Format_Word_Text(beg, end)
  " indent first-level bullets
  execute a:beg . ',' . a:end . 'g/•/norm >>cf	- '
  " indent 2nd-level bullets
  execute a:beg . ',' . a:end . 'g/^\s*o/norm >>>>cf	- '
  " indent 3rd-level bullets
  execute a:beg . ',' . a:end . 'g/^\s*/norm >>>>>>cf	- '
  " format all list items (word-wrap lines to be less than 80-chars)
  execute a:beg . ',' . a:end . 'g/^\s*-/norm f-gqq'
  return 0
endfunction

command! -range FormatWordText call Format_Word_Text(<line1>, <line2>)

inoremap <buffer> <silent> T>  =strftime("%Y%m%d")<cr><space>
