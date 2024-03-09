(module dotfiles.module.mappings
  {autoload {a aniseed.core
             nvim aniseed.nvim }})

;;;; {{{ Mapping utility functions
(defn- noremap [mode from to opts]
  "sets a mapping with {:noremap true}."
  (let [_mode (if (= nil mode) "n" mode)]
    (vim.keymap.set _mode from to opts)))

(defn- define-mappings [mode ...]
  (each [_ [lhs rhs opts] (ipairs [...])]
    (noremap mode lhs rhs (a.merge {:noremap true} opts))))

(defn- unmap [mode ...]
  "unmap keybindings for the given mode(s)"
  (each [_ mapping (ipairs [...])]
    (when (not= "" (vim.fn.maparg mapping mode))
        (vim.keymap.del (assert mode "mode required") mapping))))
;;;; }}}

;;;; {{{ Normal Mode Mappings
;;; {{{ functions
(defn- toggle-window-diff []
  "toggle diff-mode in current tab"
  (.. "<cmd>windo " (if vim.o.diff "diffoff" "diffthis") "<cr>") )

;; {{{ yeet operator functions - copy, replace, delete, move, swap
(defn- yeet-copy [start end cursor]
  "copy line at `start` and insert it after `end`"
  (let [[_ curline curcol] cursor]
      (nvim.buf_set_lines 0 end end true [(vim.fn.getline start)])
      (vim.fn.cursor (if (< end curline) (+ 1 curline) curline) curcol)))

(defn- yeet-move [start end cursor]
  "move line at `start` to the line after `end`"
  (let [[_ curline curcol] cursor
        line (vim.fn.getline start)
        up? (< end curline)]
    (if up?
      (do ;; delete start (bottom) line then insert it at end
        (nvim.buf_set_lines 0 (+ -1 start) start true [])
        (nvim.buf_set_lines 0 (+ -1 end) (+ -1 end) true [line])
        (vim.fn.cursor curline curcol))
      (do ;; insert line at end (bottom) then delete start
        (nvim.buf_set_lines 0 end end true [line])
        (nvim.buf_set_lines 0 (+ -1 start) start true [])
        (vim.fn.cursor curline curcol)))))

(defn- yeet-swap [start end cursor]
  "swap `start` and `end` lines"
  (let [[_ curline curcol] cursor
        startline (vim.fn.getline start)
        endline (vim.fn.getline end)]
    (nvim.buf_set_lines 0 (+ -1 end) end true [startline])
    (nvim.buf_set_lines 0 (+ -1 start) start true [endline])
    (vim.fn.cursor curline curcol)))
;; }}}

(defn- append [start end cursor]
  "prompt for a string to append to the end of the given range"
  (let [[_ curline curcol] cursor]
        (vim.fn.cursor curline curcol))
  (let [s (if (< start end) start end)
        e (if (< start end) end start)
        input (vim.fn.input {:prompt (.. "Append: ")
                             :cancelreturn :<CANCELLED>})]
       (when (not= input :<CANCELLED>)
         (vim.cmd (.. "keeppatterns " s "," e "s/$/" input "/g")))))

(defn- prepend [start end cursor]
  "prompt for a string to prepend to the beginning of the given range
  (ignores leading whitespace)"
  (let [[_ curline curcol] cursor]
        (vim.fn.cursor curline curcol))
  (let [s (if (< start end) start end)
        e (if (< start end) end start)
        input (vim.fn.input {:prompt (.. "Prepend: ")
                             :cancelreturn :<CANCELLED>})]
       (when (not= input :<CANCELLED>)
         (vim.cmd (.. "keeppatterns " s "," e "s/^\\s*\\zs/" input "/g")))))

(defn- cword [boundaries?]
  "return the word under the cursor
  set `boundaries?` to add word-boundary markers around it for regexes"
  (if boundaries?
    (.. "\\<" (vim.fn.expand "<cword>") "\\>")
    (vim.fn.expand "<cword>")))

(defn- substitute [start end cursor]
  "replace <cword> with a prompted string"
  (let [[_ curline curcol] cursor]
        (vim.fn.cursor curline curcol))
  (let [s (if (< start end) start end)
        e (if (< start end) end start)
        cword (cword true)
        input (vim.fn.input {:prompt (.. "Replace /" cword "/ with: ")
                             :cancelreturn :<CANCELLED>})]
       (when (not= input :<CANCELLED>)
         (vim.cmd (.. "keeppatterns " s "," e "s/" cword "/" input "/g")))))

(defn- global-do [start end cursor]
  "prompt for a command to run on all lines containing <cword>"
  (let [[_ curline curcol] cursor]
        (vim.fn.cursor curline curcol))
  (let [s (if (< start end) start end)
        e (if (< start end) end start)
        cword (cword true)
        input (vim.fn.input {:prompt (.. "Replace /" cword "/ with: ")
                             :cancelreturn :<CANCELLED>})]
       (when (not= input :<CANCELLED>)
         (vim.cmd (.. "keeppatterns " s "," e "g/" cword "/" input "/g")))))

(defn- yank [msg f]
  (vim.fn.setreg "\"" (f))
  (print (.. "Yanked: " msg)))

(defn- operator [f]
  "set the given function as the operator function then start the motion"
  (let [cursor (vim.fn.getcurpos)]
     (set _G.op_fn (fn [motion-type]
                     (let [start (vim.fn.line "'[")
                           end   (vim.fn.line "']")]
                       (if (= (. cursor 2) start)
                         (f start end cursor)
                         (f end start cursor)))
                     (set _G.op_fn nil)))
     (set vim.go.operatorfunc "v:lua.op_fn")
     (nvim.feedkeys "g@" "i" false)))

(set _G.operator operator)
;;; }}}

(define-mappings "n"
  ["'" "`" {:desc "jump to line+column of a mark"}]
  [:<c-c> #(vim.cmd "echo ''") {:desc "clear status-line"}]
  [:<c-e> :3<c-e> {:desc "scroll up"}]
  [:<c-w><c-d> toggle-window-diff {:expr true :desc "toggle diff-mode in current tab"}]
  [:<c-w><c-v> "<cmd>vertical wincmd f<cr>" {:desc "open file under cursor in vertical split"}]
  [:<c-w>z "<cmd>wincmd _ | wincmd |<cr>" {:desc "open file under cursor in vertical split"}]
  [:<c-y> :3<c-y> {:desc "scroll up"}]
  [:<cr> :i<cr><Esc> {:desc "insert line-break at cursor position"}]
  ["<leader>:" "@:" {:desc "re-run the previous :command"}]
  ["<leader>." "<cmd>cd %:p:h | echo 'cd -> '.getcwd()<cr>" {:desc "cd to dir of current file"}]
  ["<leader>," "<cmd>cd .. | echo 'cd -> '.getcwd()<cr>" {:desc "cd to parent dir"}]
  [:<leader>* "<cmd>let @/ = expand(\"<cword>\") .. \"\\\\>\" | set hlsearch<cr>" {:desc "search for word under cursor without moving cursor"}]
  [:<leader>< "V`]<" {:desc "outdent what was just pasted"}]
  [:<leader>> "V`]>" {:desc "indent what was just pasted"}]
  [:<leader>bb :<c-^> {:desc "jump to []counth buffer in the buffer list"}]
  [:<leader>bB :<cmd>blast<cr> {:desc "jump to last buffer in buffer-list"}]
  [:<leader>bd "<cmd>bp|silent!<cr> bwipeout #<cr>" {:desc "delete buffer (keep splits)"}]
  [:<leader>bD :<cmd>:bwipeout!<cr> {:desc "delete buffer ignoring unsaved changes"}]
  [:<leader>bo "<cmd>silent! execute \"%bd|e#|bd#\" | echo 'Deleted all buffers except current'<cr>" {:desc "delete all buffers except the current one"}]
  [:<leader>cs "0C<C-R>=repeat(\"=\",<Space>78)<CR><Esc>0R<C-R>\"<Space><Esc>" {:desc "add section marker to end of line"}]
  [:<leader>a #(operator append) {:desc "append a string to lines in <motion>"}]
  [:<leader>C #(operator yeet-copy) {:desc "copy current line to end of motion"}]
  [:<leader>D "<cmd>%delete _<cr>" {:desc "delete all lines in buffer"}]
  [:<leader>fd "<cmd>set fdm=diff<cr>" {:desc "set fold-method to diff"}]
  [:<leader>ff "<cmd>set fdm=manual<cr>" {:desc "set fold-method to manual"}]
  [:<leader>fi "<cmd>set fdm=indent<cr>" {:desc "set fold-method to indent"}]
  [:<leader>fm "<cmd>set fdm=marker<cr>" {:desc "set fold-method to marker"}]
  [:<leader>fs "<cmd>set fdm=syntax<cr>" {:desc "set fold-method to syntax"}]
  [:<leader>G ":%g/" {:desc "do command globally"}]
  [:<leader>i #(operator prepend) {:desc "prepend a string to lines in <motion>"}]
  [:<leader>m #(operator yeet-move) {:desc "move current line to end of motion"}]
  [:<leader>nc #(vim.cmd (.. "vimgrep /" (cword true) "/ %")) {:desc "quickfix <cword> in current file"}]
  [:<leader>nC #(vim.cmd (.. "vimgrep /" (cword true) "/ " (vim.fn.getcwd) "/**/*")) {:desc "quickfix <cword> in working directory"}]
  [:<leader>ns #(operator substitute) {:desc "substitute <cword> within motion with a given word"}]
  [:<leader>nss #(substitute 1 (vim.fn.line "$") (vim.fn.getcurpos)) {:desc "substitute <cword> within the current buffer"}]
  [:<leader>ng #(operator global-do) {:desc "global-do <cword> within motion with a given word"}]
  [:<leader>ngg #(global-do 1 (vim.fn.line "$") (vim.fn.getcurpos)) {:desc "global-do <cword> within the current buffer"}]
  [:<leader>op #(if vim.o.paste ":set nopaste<cr>" ":set paste<cr>") {:expr true :desc "toggle paste mode"}]
  [:<leader>Q :<cmd>q!<cr> {:desc "quit without saving"}]
  [:<leader>q :<cmd>q<cr> {:desc "quit"}]
  [:<leader>tc #(tset vim.wo :concealcursor (if (= vim.wo.concealcursor "") "nc" "")) {:desc "toggle conceal cursor"}]
  [:<leader>s #(operator yeet-swap) {:desc "swap lines with motion"}]
  [:<leader>w :<cmd>w<cr> {:desc "save"}]
  [:<leader>yy #(yank "file contents" #(vim.api.nvim_buf_get_lines 0 0 -1 true)) {:desc "yank entire buffer to system clipboard"}]
  [:<leader>yf #(yank "file name" #(vim.fn.expand "%:t:r")) {:desc "yank current filename (without extention)"}]
  [:<leader>yF #(yank "file NAME" #(vim.fn.expand "%:t")) {:desc "yank current filename (with extention)"}]
  [:<leader>yp #(yank "file path (absolute)" #(vim.fn.expand "%:p")) {:desc "yank fullpath of current file"}]
  [:<leader>ym #(yank "1,'m" #(vim.api.nvim_buf_get_lines 0 0 (+ 1 (vim.fn.line "'m")) true)) {:desc "yank until 'm mark"}]
  [:<leader>yM #(yank "'m,$" #(vim.api.nvim_buf_get_lines 0 (vim.fn.line "'m") -1 true)) {:desc "yank from 'm mark to end of file"}]
  [:<leader>y<cr> "<cmd>let @+=@\" | echo \"transfered to clipboard\"<cr>" {:desc "transfer contents of unnamed register to system clipboard"}]
  [:gn :<cmd>bn<cr> {:desc "next buffer"}]
  [:gN :<cmd>bp<cr> {:desc "previous buffer"}]
  [:H :^ {:desc "move cursor to beginning of line"}]
  [:L :$ {:desc "move cursor to end of line"}]
  [:N #(. ["n" "N"] (+ 1 vim.v.searchforward)) {:expr true :desc "search backward"}]
  [:n #(. ["N" "n"] (+ 1 vim.v.searchforward)) {:expr true :desc "search forward"}]
  [:Q "@q" {:desc "execute the q macro"}]
  [:S "j@:" {:desc "repeat the last command on the next line"}]
  [:s :j. {:desc "repeat the last edit on the next line"}]
  [:Y :y$ {:desc "yank to end of line"}]
  [:z< #(set vim.wo.foldlevel (if (> vim.wo.foldlevel 0) (+ -1 vim.wo.foldlevel) 0)) {:desc "decrement foldlevel"}]
  [:z> #(set vim.wo.foldlevel (+ 1 vim.wo.foldlevel))  {:desc "increment foldlevel"}]
  ["z," #(set vim.wo.foldlevel (+ -1 (vim.fn.foldlevel (vim.fn.line ".")))) {:desc "set foldlevel to one less than current line"}]
  ["z." #(set vim.wo.foldlevel (vim.fn.foldlevel (vim.fn.line "."))) {:desc "set foldlevel to current line"}]
  )
;;;; }}}
;;;; {{{ Insert Mode Mappings
(define-mappings "i"
  [:hh "<esc>" {:desc "exit insert mode"}]
  [:hs "<esc>" {:desc "exit insert mode"}]
  [";]" #(do (set vim.o.paste true) (vim.cmd "call system(\"tmux paste-buffer\")") (set vim.o.paste false)) {:desc "paste from tmux clipboard"}]
  [";l" "<c-o>b<c-o>guiw<c-o>e<c-o>a" {:desc "lowercase current word"}]
  [";s" "<c-o>z=" {:desc "correct mispelled word"}]
  [";u" "<c-o>b<c-o>gUiw<c-o>e<c-o>a" {:desc "uppercase current word"}]
  [";=" "<c-o>==" {:desc "indent current line with `=`"}]
  [:<c-a> :<c-o>^ {:desc "move cursor to beginning of line"}]
  [:<c-e> :<c-o>$ {:desc "move cursor to end of line"}]
  ["<c-r><c-r>" :<c-r>+ {:desc "paste from system clipboard"}]
  )
;;;; }}}
;;;; {{{ Visual Mode Mappings
(define-mappings "x"
  [:H :^ {:desc "move cursor to beginning of line"}]
  [:L :$ {:desc "move cursor to end of line"}]
  [:N ":norm " {:desc "run normal commands on visual selection"}]
  [:s ":s/" {:desc "search+replace selected range"}]
  ["*" ":<c-u>let @/=@\"<cr>gvy:let [@/,@\"]=[@\",@/]<cr>/\\V<c-r>=substitute(escape(@/,'/\\'),'\\n','\\\\n','g')<cr><cr>" {:desc "search forward for selected text"}]
  ["#" ":<c-u>let @/=@\"<cr>gvy:let [@/,@\"]=[@\",@/]<cr>/\\V<c-r>=substitute(escape(@/,'/\\'),'\\n','\\\\n','g')<cr><cr>NN" {:desc "search backward for selected text"}]
  [:<leader>* "y:let @/ = \"<c-r>0\\\\>\"<cr>" {:desc "search for selected text without moving the cursor"}]
  ["<leader>:" "@:" {:desc "re-execute last :command"}]
  )
;;;; }}}
;;;; {{{ Command Mode Mappings
(define-mappings "c"
  ["hh" "<esc>" {:desc "exit command mode"}]
  [:<c-r><c-e> "<c-r>=getline('.')<cr>" {:desc "copy current line to command-line"}]
  [:<c-a> :<c-b> {:desc "move cursor to beginning of line"}]
  )
;;;; }}}
;;;; {{{ Operator-Pending Mappings
(define-mappings "o"
  ["'" "`" {:desc "jump to line+column of a mark"}]
  )
;;;; }}}
;;;; {{{ Terminal Mappings
(unmap "t"
        "<c-w>")

(define-mappings "t"
  ["<leader><localleader>" "<c-\\><c-n>" {:desc "exit to normal mode"}]
  )
;;;; }}}

;; vim:foldmethod=marker
