" vim:fdm=marker
if exists("b:sql_loaded") " {{{ quit if already loaded
    finish
endif
let b:sql_loaded = 1 " }}}
" {{{ settings
setlocal expandtab
setlocal noshiftround
setlocal tabstop=4
setlocal shiftwidth=4
setlocal foldmethod=indent
setlocal suffixesadd=.sql
setlocal foldignore=
setlocal commentstring=--\ %s

" {{{ plugin-specific settings
" delimitMate autocompleting angle brackets <> was messing with my shorthand
let delimitMate_matchpairs = "(:),[:],{:}"
" }}}
" }}}
" {{{ commands
command! -range AliasColumns keeppatterns <line1>,<line2> s/\s*,\?\zs\(\w\+\.\)\?\(@\?\w\+\)/[\2] = \1\2/
command! -range FixCommas keeppatterns <line1>s/\(^\|^\(\t\| \{4\}\)\+\)\zs[^,[:space:]]/ &/e
      \| keeppatterns <line1>+1,<line2>s/^\s*\zs[^,[:space:]]/,&/e
      \| keeppatterns <line1>,<line2>s/,\s*$//e
" }}}
" {{{ mappings
" {{{ text object for SELECT clause (all fields) of SQL statement
onoremap <silent>is :<c-u>call select_textobj#select_textobj(v:true)<cr>
onoremap <silent>as :<c-u>call select_textobj#select_textobj(v:false)<cr>
xnoremap <silent>is :<c-u>call select_textobj#select_textobj(v:true)<cr>
xnoremap <silent>as :<c-u>call select_textobj#select_textobj(v:false)<cr>
" }}}
" {{{ text object for FROM clause (and joins) of SQL statement
onoremap <silent>if :<c-u>call from_textobj#from_textobj(v:true)<cr>
onoremap <silent>af :<c-u>call from_textobj#from_textobj(v:false)<cr>
xnoremap <silent>if :<c-u>call from_textobj#from_textobj(v:true)<cr>
xnoremap <silent>af :<c-u>call from_textobj#from_textobj(v:false)<cr>
" }}}
" {{{ INSERT MODE
inoremap <buffer> A>  AND<space>
inoremap <buffer> B>  BEGIN<cr>END<esc>O
inoremap <buffer> BC> <esc>!!cat ~/templates/trycatch_template.sql<cr>V`]=o
inoremap <buffer> BT> BEGIN TRAN<cr><cr><cr>WHILE @@TRANCOUNT > 0 ROLLBACK TRAN<esc><<kO
inoremap <buffer> C>  CASE<space>WHEN<esc>o<tab>END<esc>kA<space>
inoremap <buffer> CR> CONVERT()<left>
inoremap <buffer> CS> CAST()<left>
inoremap <buffer> D>  DECLARE<cr><tab>
inoremap <buffer> DD> <esc>!!cat ~/templates/declaration.sql<cr>j$i
inoremap <buffer> DT> <esc>!!printf 'DECLARE @ TABLE (\n)'<cr>=jf@a
inoremap <buffer> E>  EXISTS<space>(<cr><tab>SELECT<space>8<cr>FROM t_<cr>)<esc>kA
inoremap <buffer> F>  FROM t_
" automatically add a group-by clause that uses all non-aggregate fields from
" the select statement
imap     <buffer> G>  GROUP BY<esc>yis'.p:keepp .,/\(\n\s*\(having\<bar>order by\)\<bar>\n\n\<bar>\%$\)/g/[()]/d<cr>
inoremap <buffer> H>  HAVING<tab>
inoremap <buffer> I>  INSERT<space>INTO
" I find it a little silly that I don't have a good way to type my company's
" name
inoremap <buffer> K>  K”rber<space>
inoremap <buffer> L>  LEFT<space>OUTER<space>JOIN<space>t_<cr>ON<tab><esc>>>kA
inoremap <buffer> N>  INNER<space>JOIN<space>t_<cr>ON<tab><esc>>>kA
inoremap <buffer> NV  NVARCHAR()<left>
inoremap <buffer> O>  ORDER<space>BY<cr><tab>
inoremap <buffer> P>  PARTITION<space>BY<space>
inoremap <buffer> S*  SELECT 8
inoremap <buffer> ST> SELECT TOP 1<cr><tab>
inoremap <buffer> S>  SELECT<cr><tab>
" insert current date (I know 'T' is a bad mneumonic for 'Date"; think 'Tag')
inoremap <buffer> <silent> T>  =strftime("%Y%m%d")<cr><space>
inoremap <buffer> U>  UPDATE<space><cr>SET<tab><esc>kA
inoremap <buffer> V>  OVER<space>()<left>
inoremap <buffer> W>  WHERE<space>
inoremap <buffer> WN  WITH<space>(NOLOCK)
inoremap <buffer> X>  ISNULL(,<space>'')<c-o>F,
" }}}
" {{{ NORMAL
" swap operands of the expression on the current line
nnoremap <buffer> <silent> <leader>O !!sql mappredicate sio<cr>

" copy my most commonly-used SchemaHistory query (for current file) to clipboard
nnoremap <buffer> <localleader>sh :!printf "SELECT * FROM SchemaHistory..SchemaHistory WHERE ObjectName = '%:t:r' ORDER BY EventDate DESC"<bar>clip<cr><cr>
nnoremap <buffer> <localleader>l :!printf "SELECT TOP 20 logged_on_local, log_sequence, details, * FROM ADV..t_log_message ORDER BY logged_on_utc DESC"<bar>clip<cr><cr>

" TODO: rewrite this in lua
" create a sidebar that displays all of the tables present in the current sproc
" function! PrintTabledef(table)
"   let l:td_file="\"$(proot)/indexes/tabledef.index.txt\""
"   let l:cmd="awk -F'\t' -v table=".a:table." 'match($1, \"^\" table \"$\") == 1 { print $3 }'"
"   exec ":read !" .l:cmd." < ".l:td_file " | tr -d $'\\r'"
" endfunction
" function! TableSidebar() " {{{
"     let l:filename = expand("%")
"     let l:proot=shell#proot(expand("%:p"))
"     if bufexists("tables")
"         exec "b" . bufnr("tables")
"         %d
"         exec "1!sql find_tables " . l:filename
"     else
"         vert split
"         enew
"         file tables
"         setlocal
"             \ buftype=nofile
"             \ bufhidden=wipe
"             \ shiftwidth=2
"             \ tabstop=2
"             \ suffixesadd=.sql
"             \ foldmethod=indent
"             \ noexpandtab
"         if l:proot != ""
"             exec "setlocal path=" . l:proot . "/tabledefs/"
"             " nnoremap <buffer> <cr> m`:read !cat $(proot)/tabledefs/<c-r><c-w>.sql<cr>v''j>gv>
"             nnoremap <buffer> <cr> m`:call PrintTabledef("<c-r><c-w>")<cr>v''j>gv>
"             nnoremap <buffer> ] :call search('^\t\zst_\w\+', 'sw')<cr>
"             nnoremap <buffer> [ :call search('^\t\zst_\w\+', 'swb')<cr>
"             nmap     <buffer> yI yai:let @"=system("sql p gn", getreg('"'))<cr>
"             nnoremap <buffer> gq :q<cr>
"             " create table <c-r><c-w>\_.\{-})\?);\?$
"         endif
"
"         exec "1!sql find_tables " . l:filename
"     endif
" endfunction " }}}
" nnoremap <buffer> <tab> :call TableSidebar()<cr>

" prepend each line at the current indent level with a comma (except prepend
" the first such line with a space)
nmap <silent> <leader>is, ^vii<c-v>I,<esc>r<space>
" }}}
" {{{ VISUAL
" uppercase all sql keywords
vnoremap <buffer> <silent> <leader>U :!sql uppercase<cr>

" convert a single-line simple CASE expression to an IIF call
" e.g. CASE WHEN pkd.container_type = 'CS' THEN pkd.container_type ELSE NULL END
" e.g. IIF(pkd.container_type = 'CS', pkd.container_type, NULL)
vnoremap <buffer> <silent> <leader>I :<c-u>keeppatterns '<,'>g/CASE.\+ELSE.\+END/norm /CASE<c-v><cr>d2wiIIF(<c-v><esc>/ THEN<c-v><cr>dei,<c-v><esc>/ ELSE<c-v><cr>dei,<c-v><esc>/ END<c-v><cr>r)ldw<cr>

" generate insert statement for the highlighted table plus data-rows
" (tab-separated, most often pasted directly from SSMS)
vnoremap <buffer> <silent> <leader>i :!sql project table_insert<cr>

" automatically give [aliases] to all highlighted columns
" SELECT                     -> SELECT
"    @pick_id                ->    [@pick_id]          = @pick_id
"   ,@pick_qty_in_tote       ->   ,[@pick_qty_in_tote] = @pick_qty_in_tote
vmap <buffer> <leader>,] :AliasColumns<cr>gvgl=

" prepend each line at the current indent level with a comma (except prepend
" the first such line with a space)
vnoremap <localleader>f, :FixCommas<cr>
" }}}
" }}}
