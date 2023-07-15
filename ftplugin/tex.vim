iab \p \paragraph{}

setlocal shiftwidth=2
setlocal tabstop=2
setlocal foldmethod=indent

" nnoremap <buffer> <leader>W :!pdflatex % && click %.pdf<cr>
nnoremap <buffer> <leader>v :!pdflatex -output-directory "%:p:h" "%" && click "%:r.pdf"<cr>

inoremap <buffer> ,.n <cr>\par<cr>
inoremap <buffer> ,.i \item<cr>

" abbreviations
ia <buffer> -> $\rightarrow$
ia <buffer> <- $\leftarrow$
ia <buffer> => $\Rightarrow$
ia <buffer> <= $\Leftarrow$
