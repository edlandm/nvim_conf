" vim:fdm=marker
if exists("b:sql_loaded") " {{{ quit if already loaded
    finish
endif
let b:sql_loaded = 1 " }}}
" {{{ settings
setlocal noexpandtab
setlocal noshiftround
setlocal tabstop=4
setlocal shiftwidth=4
setlocal foldmethod=indent
setlocal suffixesadd=.sql
setlocal foldignore=
let maplocalleader=','

" {{{ plugin-specific settings
" delimitMate autocompleting angle brackets <> was messing with my shorthand
let delimitMate_matchpairs = "(:),[:],{:}"
" }}}
" }}}
" {{{ commands
command! Gotos call sql#gotos()
command! -nargs=1 SearchApp call sql#search_adv(<args>)
command! UniqueLines call sql#unique_nonnull_results()
command! -range Prql <line1>,<line2>call sql#prql()
command! -range AliasColumns keeppatterns <line1>,<line2> s/\s*,\?\zs\(\w\+\.\)\?\(@\?\w\+\)/[\2] = \1\2/
command! CleanNewSprocs argdo call sql#split_sproc_clean()
command! -nargs=1 -bar Fzsql call sql#fzsql(<args>)
" add new pastedump of sprocs to master, commit them, then hop back to current
" branch and rebase
" - the --quiet flags are helpful in the event that you are already on master
" - reset the screen at the end because `gunt|xargs vim` messes up the screen
"   for some reason
command! AddNewSprocs !git checkout master --quiet;paste|sql sp;gunt|xargs vim && { gaf git checkout --quiet; git rebase master --quiet; };reset
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
" use FZF to insert a variable
" inoremap <buffer> @#  <esc>:call sql#fzf_grab('variable')<cr>A
inoremap <buffer> <silent> @# <c-o>:call shell#cmd('fzf', 'sql variables -s ' . shellescape(expand('%')))<cr><c-r>"

" use fuzzy-finder to open one of my sql scripts in a new buffer
" TODO: move this to sql.vim function
" nnoremap <buffer> <silent> <tab> :call shell#cmd('fzf', "find ~/s/sql/ -name '*.sql'")<cr>:enew<cr>:set ft=sql<cr>:.read <c-r>"<cr>:1d<cr>
"

" Turn `WHERE pkd hum wh_id` into `WHERE pkd.wh_id = hum.wh_id`
" or turn `WHERE pkd wh_id` into `WHERE pkd.wh_id = @wh_id`
" Works after `WHERE`, `AND`, `ON`, `HAVING`
inoremap <buffer> _>  <esc>!!sql mappredicate $(sql -c expandexpression)<cr>A
" like the above but on steroids. Main difference is that you define table1
" and table2 between the WHERE and the first comma.
" NOTE: Works for WHERE, ON, and HAVING
" turn:
"   WHERE o wwp,wwu_username,sto.order_id,is_cutoff 1
" into:
"   WHERE o.wwu_username = wwp.wwu_username
"     AND o.order_id = sto.order_id
"     AND o.is_cutoff = 1
inoremap <buffer> __>  <esc>!!~/bin/where_parse<cr>A
" Same as above but changes @wh_id to @in_wh_id
inoremap <buffer> _<<  <esc>!!sql mappredicate $(sql -c expandexpression) -i<cr>A
" Same as above but changes @wh_id to @out_wh_id
inoremap <buffer> _<>  <esc>!!sql mappredicate $(sql -c expandexpression) -o<cr>A
" }}}
" {{{ NORMAL
" expand shorthand and clean statement above cursor
nnoremap <buffer> _ vip:Prql<cr>'.
vnoremap <buffer> _ :Prql<cr>'.

" For whole paragraph object (that cursor is in)
" move commas from the end of the line to the beginning of the line and space
" it with a tab-character
" nnoremap <buffer> <silent> <leader>,ip vip:'<,'>g/,$/normal $xj^P/<cr>gv:g/,\S/normal f,Xp/<cr>gv:g/	 \S/normal f x/e<cr>
" nnoremap <buffer> <silent> <leader>,ap vap:'<,'>g/,$/normal $xj^P/<cr>gv:g/,\S/normal f,Xp/<cr>gv:g/	 \S/normal f x/e<cr>

" format (align and apply uniform comma-style) DECLARE blocks
nnoremap <buffer> <silent> <leader>,, vip:!sql fd<cr>
nnoremap <buffer> <silent> <leader>,c vip:!sql fd -c<cr>
nnoremap <buffer> <silent> <leader>,C vip:!sql fd -C<cr>

" move commas from the end of the line to the beginning of the line.
" meant to be used when visually selecting the columns in a SELECT statement
vnoremap <buffer> <silent> <leader>,, :<c-u>call sql#fix_commas()<cr>

" turn:
"   WHERE ols.load_number = @in_load_number
"     AND ols.wh_id = @in_wh_id
" into:
"   WHERE ols.wh_id = @in_wh_id
"     AND ols.load_number = @in_load_number
" NOTE: cursor must be placed on upper of the two lines

nnoremap <buffer> <silent> <localleader>,s 0wf Dj0welPlDkpj^

" paste in and format sproc call from the debugger
nnoremap <buffer> <silent> <localleader>p :call sql#aa_paste_debugger_output()<cr><cr>

" commands for viewing and yanking sql variables with fuzzy-finder
" browse all variables in the current file; selecting one will search for it
nnoremap <buffer> <silent> ,/ :call shell#cmd('fzf-search', 'sql variables -s ' . shellescape(expand('%')))<cr>
" browse the variables in the current files via fuzzy-finder; selecting one
" will yank it to the unnamed register (@")
" this first one browses all variables; the ones below use various filters
nnoremap <buffer> <silent> ,vv :call shell#cmd('fzf', 'sql variables -s ' . shellescape(expand('%')))<cr>
" filters:
"     -i | @in variables
"     -l | local variables  (not @in_ or @out_)
"     -o | @out variables
"     -p | parameters (@in_ and @out_)
"     -u | undeclared variables
"     -U | unused variables
nnoremap <buffer> <silent> ,vi :call shell#cmd('fzf', 'sql variables -si ' . shellescape(expand('%')))<cr>
nnoremap <buffer> <silent> ,vl :call shell#cmd('fzf', 'sql variables -sl ' . shellescape(expand('%')))<cr>
nnoremap <buffer> <silent> ,vo :call shell#cmd('fzf', 'sql variables -so ' . shellescape(expand('%')))<cr>
nnoremap <buffer> <silent> ,vp :call shell#cmd('fzf', 'sql variables -sp ' . shellescape(expand('%')))<cr>
nnoremap <buffer> <silent> ,vu :call shell#cmd('fzf', 'sql variables -su ' . shellescape(expand('%')))<cr>
nnoremap <buffer> <silent> ,vU :call shell#cmd('fzf', 'sql variables -sU ' . shellescape(expand('%')))<cr>

" search through SQL statements using fzf to find and jump to the statement
nnoremap <leader>/ :Fzsql expand('%') <bar> silent! normal zO<cr>
nnoremap <leader><localleader>/ :Fzsql join(uniq(argv()), ' ') <bar> silent! normal zO<cr>
" nnoremap <leader>/ :call sql#fzsql(expand("%"))<cr>

" display lines of all variable definitions
" also opens the command-line (:) so that you can just type a line-number and
" press <cr> to jump to it
nnoremap <buffer> <silent> <leader>,v :g/^\s*\(declare\s\+\)\?\(,\s*\)\?@\w\+\s\+\(output\)\@!\S\+\(\s\+=\s\+.\+\|\s\+output.*\)\?\(\s\+--.*\)\?$/#<cr>:

" create a vertical side-bar populated with all variable-declaration lines
nnoremap <buffer> <silent> <leader>,V :call shell#cmd('sidebar', 'sql variables -V ' . shellescape(expand('%')))<cr>

" display lines of all DELETE/UPDATE/MERGE/EXECUTE/INSERT statements
" (basically, anywhere that manipulates table-data)
" also opens the command-line (:) so that you can just type a line-number and
" press <cr> to jump to it
nnoremap <buffer> <silent> ,u :g/\(--\s*\)\@<!\(update\<bar>insert\<bar>merge\<bar>delete\<bar>exec\%[ute]\)\>/#<cr>:

" jump to next/previous SQL statement
nnoremap <buffer> <silent> ) :call sql#next_statement('')<cr>
nnoremap <buffer> <silent> ( :call sql#next_statement('b')<cr>
vnoremap <buffer> <silent> ) :call sql#next_statement('')<cr>
vnoremap <buffer> <silent> ( :call sql#next_statement('b')<cr>

" search sproc definitions
nnoremap <buffer> <localleader>d :call sql#sprocdef('')<cr>
" insert sproc Test Execution block on current line
nnoremap <buffer> <localleader>D :call sql#sprocdef(expand('%'))<cr>

" properly indent the AND on the current line
" nnoremap <buffer> <silent> <leader>a ==:keeppatterns s/\(\t\)\?\(AND \)/\1  \2/<cr>
nnoremap <buffer> <silent> <leader>a :set opfunc=operators#sql_indent_and<CR>g@

" swap operands of the expression on the current line
nnoremap <buffer> <silent> <leader>O !!sql mappredicate sio<cr>

" wrap the cursor-word with ISNULL(<cword>, '')
nnoremap <buffer> <leader>x ciWISNULL(,<space>'')<c-o>F,<c-r>"<esc>$

" use fzf to select an index file to search, then use fzf to search the
" selected index file. The final selection is inserted below the current line.
nnoremap <buffer> <localleader>i o<esc>:silent! .!op -i<cr>:redraw!<cr>==

" use fzf to select a tabledef file to search, then use fzf to search the
" selected file. The final selection is inserted below the current line.
nnoremap <buffer> <localleader>t :silent! !op -t<cr>:redraw!<cr>

" use fzf to select a tabledef file to search, then use fzf to search the
" selected file. The final selection is inserted below the current line.
nnoremap <buffer> <leader>nt :call shell#cmd('fzf', 'cat $(proot)/tabledefs/' . '.sql')<cr>

" copy my most commonly-used SchemaHistory query (for current file) to clipboard
nnoremap <buffer> <localleader>sh :!printf "SELECT * FROM SchemaHistory..SchemaHistory WHERE ObjectName = '%:t:r' ORDER BY EventDate DESC"<bar>clip<cr><cr>
nnoremap <buffer> <localleader>l :!printf "SELECT TOP 20 logged_on_local, log_sequence, details, * FROM ADV..t_log_message ORDER BY logged_on_utc DESC"<bar>clip<cr><cr>

" copy SchemaHistory script for current project to clipboard
nnoremap <buffer> <localleader><localleader>sh :!sql p sh <bar> clip<cr><cr>

" copy my architect_me.sql script to the clipboard
nnoremap <buffer> <localleader>a :!clip < ~/s/sql/architect_me.sql<cr><cr>

" generate a table-variable and insert
nnoremap <buffer> <localleader><localleader>t :.!sql p ti  < <(paste)<left><left><left><left><left><left><left><left><left><left><left>

" split list into multiple lines
" nnoremap <buffer> <localleader>gs :keeppatterns s/\((\<bar>, \)/&\r/g<cr>=ibvib:keeppatterns '<,'>s/\s*$//<cr>
nnoremap <buffer> <localleader>gs :keeppatterns s/\((\<bar>, \)/&\r/g<cr>=ibvib:keeppatterns '<,'>s/\s*$//<cr>

if exists(":EasyAlign") " {{{ easy-align mappings
    " align fields and values in sql declare statements
    nmap gld mzglip glip=`z

    " align column aliases in SQL
    " e.g.
    "  CAST(('N') AS CHAR(1))                        as [function]
    " ,CAST(('O') AS CHAR(1))                        as [activity_type]
    " ,CAST(CONCAT(@work_type, '06') AS VARCHAR(15)) as [work_type]
    vnoremap gL :EasyAlign /\(as \)\?\[/ r0<cr>

    " use easy-align to align THEN predicates (from case statements in SQL)
    vnoremap gT :EasyAlign /THEN/ r1<cr>
endif " }}}

" create a sidebar that displays all of the tables present in the current sproc
function! PrintTabledef(table)
  let l:td_file="\"$(proot)/indexes/tabledef.index.txt\""
  let l:cmd="awk -F'\t' -v table=".a:table." 'match($1, \"^\" table \"$\") == 1 { print $3 }'"
  exec ":read !" .l:cmd." < ".l:td_file " | tr -d $'\\r'"
endfunction
function! TableSidebar() " {{{
    let l:filename = expand("%")
    let l:proot=shell#proot(expand("%:p"))
    if bufexists("tables")
        exec "b" . bufnr("tables")
        %d
        exec "1!sql find_tables " . l:filename
    else
        vert split
        enew
        file tables
        setlocal
            \ buftype=nofile
            \ bufhidden=wipe
            \ shiftwidth=2
            \ tabstop=2
            \ suffixesadd=.sql
            \ foldmethod=indent
            \ noexpandtab
        if l:proot != ""
            exec "setlocal path=" . l:proot . "/tabledefs/"
            " nnoremap <buffer> <cr> m`:read !cat $(proot)/tabledefs/<c-r><c-w>.sql<cr>v''j>gv>
            nnoremap <buffer> <cr> m`:call PrintTabledef("<c-r><c-w>")<cr>v''j>gv>
            nnoremap <buffer> ] :call search('^\t\zst_\w\+', 'sw')<cr>
            nnoremap <buffer> [ :call search('^\t\zst_\w\+', 'swb')<cr>
            nmap     <buffer> yI yai:let @"=system("sql p gn", getreg('"'))<cr>
            nnoremap <buffer> gq :q<cr>
            " create table <c-r><c-w>\_.\{-})\?);\?$
        endif

        exec "1!sql find_tables " . l:filename
    endif
endfunction " }}}
nnoremap <buffer> <tab> :call TableSidebar()<cr>

" fully expand:
"     INSERT INTO t_table (
"     )
" --
" Into a fully fleshed out insert statement.
" Cursor must be placed within the table name.
" TODO: turn this into a function
nnoremap <leader>,i :read !awk '{ print "\t" $1 " -- ",$2,$3,$4 }' $(proot)/tabledefs/<cword>.sql<cr>glib<space>I<space><esc>f<space>xbyibvibjoSELECT<esc>pjvii:s/^\(\s\+,\?\)\(\w.*$\)/\1 -- \2/<cr>"<h

" paste WW statement with fields replaced by variables
nnoremap <silent> <leader>PW !!paste -b -s<bar>sed -r "s/'?~(\w+)~'?/@\L\1\E/g"

" prepend each line at the current indent level with a comma (except prepend
" the first such line with a space)
nmap <silent> <leader>is, ^vii<c-v>I,<esc>r<space>
" }}}
" {{{ VISUAL
"turn each line into a SQL list item (string)
vnoremap <buffer> ,l :!xargs sql list<cr>
" indent visually selected 'AND' lines with two spaces instead of a full tab
vnoremap <buffer> <silent> <leader>a =:keeppatterns '<,'>s/\(\t\)\?\(AND \)/\1  \2/<cr>
" uppercase all sql keywords
vnoremap <buffer> <silent> <leader>U :!sql uppercase<cr>
" swap the order of the tables in join conditions
" `ON   sto.type = pkd.pick_id` -> `ON   pkd.pick_id = sto.type`
vnoremap <buffer> <silent> <leader>s :s/^.\{-}\<\zs\(\w\+\.\w\+\)\(.\{-}\<\)\(\w\+\.\w\+\)\ze/\3\2\1/e<cr>gv

" jump to the definition of the selected word / word under the cursor
nnoremap <buffer> <silent> <leader>nd /^\s\+declare\_.\{-}\n\?\s\+\zs<c-r><c-w>\>\ze\s\+\(=\)\@!.\+$<cr>
vnoremap <buffer> <silent> <leader>nd y/^\s\+declare\_.\{-}\n\?\s\+\zs<c-r>"\>\ze\s\+\(=\)\@!.\+$<cr>

" indent/outdent keeping sql statements well-formated while doing so
" TODO: create SqlIndent function and/or SqlIndent SqlOutdent commands that
" also nicely format AND lines in WHERE clause
vnoremap <buffer> <silent> > >gv:s/\(select\<bar>group by\<bar>order by\)\n\t*\zs\w\ze.\+\n\t*,/ &/e<cr>gv
vnoremap <buffer> <silent> < <gv:s/\(\t*\)\(select\<bar>group by\<bar>order by\)\n\zs\s*\(\w\)\ze.\+\n\t*,/\1\t \3/e<cr>gv

" convert a single-line simple CASE expression to an IIF call
" e.g. CASE WHEN pkd.container_type = 'CS' THEN pkd.container_type ELSE NULL END
" e.g. IIF(pkd.container_type = 'CS', pkd.container_type, NULL)
" (the whole case expression must be on the same line)
" '<,'>s/\(.\{-}=\)\s*CASE\s\+WHEN\s\+\(.\+\S\)\s\+THEN\s\+\(.*\S\)\s\+ELSE\s\+\(.*\S\)\s\+END\s*$/\1 IFF(\2, \3, \4)/e
" "'<,'>norm /CASEd2wiIIF(/ THENdei,/ ELSEdei,/ ENDr)ldw
vnoremap <buffer> <silent> <leader>I :<c-u>keeppatterns '<,'>g/CASE.\+ELSE.\+END/norm /CASE<c-v><cr>d2wiIIF(<c-v><esc>/ THEN<c-v><cr>dei,<c-v><esc>/ ELSE<c-v><cr>dei,<c-v><esc>/ END<c-v><cr>r)ldw<cr>
" vnoremap <buffer> <silent> <leader>I :<c-u>keeppatterns '<,'>s/\(.\{-}=\)\s*CASE\s\+WHEN\s\+\(.\+\S\)\s\+THEN\s\+\(.*\S\)\s\+ELSE\s\+\(.*\S\)\s\+END\s*$/\1 IFF(\2, \3, \4)/e

" generate insert statement for the highlighted table plus data-rows
" (tab-separated, most often pasted directly from SSMS)
vnoremap <buffer> <silent> <leader>i :!sql project table_insert<cr>

" turn the visual selection into variable definitions
" NOTE: only two lines. first line is the fieldnames, second is the values
vnoremap <buffer> <leader><localleader>t :!sql tv<cr>

vnoremap <buffer> <leader>= !sqlf<cr>

" Parameter Switch
" Turn:
"   ,:Transaction Code: /* @in_tran_type */
" Into:
"   ,@in_tran_type  /* :Transaction Code:*/
vnoremap <leader>,ps :g/:/norm f:df:f@P;df F,p<cr>
" }}}
" Not sure where to put this, but its a regex to highlight all columns in
" a SELECT statement
" "^.\{-}\(\s\+,\?\w\+\.\zs\w\+\ze\|\(as\s\+\|\s\+\[\)\zs\w\+\ze\]\?\s*$\|^\s\+,\?\[\zs\w\+\ze\]\s\+=\)

" automatically give [aliases] to all highlighted columns
" SELECT                     -> SELECT
"    @pick_id                ->    [@pick_id]          = @pick_id
"   ,@pick_qty_in_tote       ->   ,[@pick_qty_in_tote] = @pick_qty_in_tote
vmap <buffer> <leader>,] :AliasColumns<cr>gvgl=

" }}}
" {{{ abbreviations
" words to capitalize
ia bit BIT
" ids
function! Eatchar(pat)
    let c = nr2char(getchar(0))
    return (c =~ a:pat) ? '' : c
endfunction

let sql_iab_ids = {
            \ "c": "container",
            \ "h": "hu",
            \ "l": "location",
            \ "o": "order",
            \ "p": "pick",
            \ "q": "queue",
            \ "u": "unique",
            \ "v": "pack_wave_id",
            \ "w": "wh"
            \ }
for [k, v] in items(sql_iab_ids)
    exe "ia <buffer> ".k."i ".v."_id<c-r>=Eatchar('\\s')<cr>"
endfor

ia <buffer> oo order_number<c-r>=Eatchar('\s')<cr>
ia <buffer> cn control_number<c-r>=Eatchar('\s')<cr>
ia <buffer> ct control_type<c-r>=Eatchar('\s')<cr>
ia <buffer> wt work_type<c-r>=Eatchar('\s')<cr>
ia <buffer> pa pick_area<c-r>=Eatchar('\s')<cr>
" }}}
