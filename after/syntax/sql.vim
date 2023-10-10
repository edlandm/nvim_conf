syn keyword sqlKeyword output goto
syn keyword sqlType nvarchar int bigint smallint bit date time datetime
syn keyword sqlType varchar char nchar tinyint money decimal xml
syn keyword sqlFunction getdate count left right concat isnull upper lower ceiling formatmessage
syn keyword sqlTodo todo
syn keyword sqlStatement declare exec execute merge set contained except
                        \ intersect while break
syn keyword sqlStatement end rollback commit contained

syn match sqlGoto '[a-zA-Z_]\+\ze:'


syn match sqlVar '@[a-zA-Z_]'
syn match sqlVarMarker '@'
" syn match sqlChangeComment contained '\([a-zA-Z]\{2,3}[ 	-]\+[0-9.\/]\{8,10}\|[0-9.\/]\{8,10}[ 	-]\+[a-zA-Z]\{2,3}\)'

syn match sqlComment "--.*$" contains=sqlChangeComment,sqlTodo
" syn region sqlComment start="/\*" end="\*/" contains=sqlChangeComment
    " \ fold keepend

" syn region sqlBlock
    " \ start='^\s*\c\(begin\).*$'
    " \ end='^\s*\c\(end\|commit\|rollback\).*$'
    " \ fold transparent contains=ALL keepend

" syn region sqlBlock
    " \ start='^.*\c\(case\).*$'
    " \ end='^.*\c\(end\).*$'
    " \ fold transparent contains=ALL keepend

" syn region sqlFold
    " \ start='^\s*\zs\c\(Create\|Update\|Alter\|Select\|Insert\|Declare\|Exec\|Merge\)'
    " \ end=';$\|^$'
    " \ fold transparent contains=ALL

" regex to match a SQL statement
" ^\s\?\(\s*\)\(--\)\@!\zs\(insert\|select\|update\|delete\|merge\|;with\|alter\|declare\|exec\)\_.\{-}\ze\n\(\s*\(begin\|end\)\|\1)\)\{-}\_$

syn match sqlStatement
      \ keepend
      \ /^\s\?\(\s*\)\(--\)\@!\zs\(INSERT\|SELECT\|UPDATE\|DELETE\|MERGE\|;WITH\|ALTER\|DECLARE\|EXEC\)\_.\{-}\ze\n\(\s*\(BEGIN\|END\)\|\1)\)\{-}\_$/
      \ fold transparent contains=ALL

hi def link sqlVarMarker        Boolean
" hi def link sqlChangeComment    Todo
hi! def link sqlStatement Statement
hi! def link sqlKeyword   Statement

hi def link sqlGoto Underline
