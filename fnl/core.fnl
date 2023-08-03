;; vim:fdm=marker
(module dotfiles.module.core
  {require {a    aniseed.core
            nvim aniseed.nvim}
   import-macros [[ac :aniseed.macros.autocmds]]})

;;;; {{{ Core Editor Configuration/Environment
;;; {{{ functions
(defn- setopts [namespace ...]
  "convenience function for setting options in bulk"
  (each [_ opt (ipairs [...])]
    (let [[o v] (case (type opt)
                  "string" [opt true]
                  "table" opt)]
      (tset (. vim (or namespace :o)) o v))))
;; }}}
;;; {{{ vim environment variables
(setopts :env
  [:$BASH_ENV "~/.vim_bashrc"]) ; }}}
;;; {{{ set options
(setopts nil
  :cursorline
  :expandtab
  :ignorecase
  ; :lazyredraw - disabled for noice.nvim
  :list
  :number
  :relativenumber
  :shiftround
  :smartcase
  :splitbelow
  :splitright
  :termguicolors
  :wildignorecase
  [:cdpath "~/,.,./*"]
  [:completeopt "longest,menuone,preview"]
  [:diffopt "filler,vertical,iwhite,hiddenoff"]
  [:display "lastline,uhex"]
  [:equalalways false]
  [:fileencodings "utf-8,default,latin1"]
  [:foldopen "insert,percent,quickfix,tag,undo,mark"]
  [:fillchars "fold: "]
  ;; TODO: find a way to write this in lua
  ; [:foldtext "util#get_foldtext()"]
  [:formatoptions "tcq1nb"]
  [:helplang "en"]
  [:lcs "tab:¦ ,trail:·"]
  [:maxmapdepth 20]
  [:nrformats "hex"]
  [:omnifunc "syntaxcomplete#Complete"]
  [:pastetoggle "<F8>"]
  [:path "~/,."]
  [:pumheight 15]
  [:scrolloff 3]
  [:sessionoptions "blank,buffers,curdir,folds,options,localoptions,tabpages,winsize,"]
  [:shelltemp false]
  [:shiftwidth 4]
  [:suffixes ".bak,~,.o,.h,.info,.swp,.obj,.pyc"]
  [:suffixesadd "txt,html,md,sh"]
  [:swapfile false]
  [:switchbuf "useopen"]
  [:synmaxcol 500]
  [:tabpagemax 5]
  [:tabstop 4]
  [:tags "./tags,tags,./.tags"]
  [:textwidth 78]
  [:timeoutlen 450]
  ;; next two options disable "Thanks for Flying Vim" message
  [:title false]
  [:titleold ""]
  [:wildignore ".hg,.git,.svn,*.aux,*.out,*.toc,*.jpg,*.bmp,*.gif,*.png,*.jpeg,*.o,*.obj,*.exe,*.dll,*.manifest,#.spl,#.sw?,#.DS_Store,#.pyc"]
  [:wildmode "list:longest"]
  ) ; }}}
;;; {{{ set global variables
(setopts :g
  :omni_sql_no_default_maps
  ;; insert javascript to allow for interractive folds for the html file
  ;; output from :TOHtml
  :html_dynamic_folds
  :fnl_loaded
  [:aniseed#env true]
  [:netrw_browsex_viewer "xdg-open"]) ; }}}
;;;; }}}
;;; {{{ autocommands
;; {{{ return to last edit position when opening files
(ac.augroup :jump-to-last-edit-pos
  [[:BufReadPost]
   {:pattern :*
    :command "silent! call setpos('.', getpos(\"'\\\"\"))"}]) ; }}}
;;; {{{ set color-column (for some reason it needs to be set with vim.opt)
(ac.augroup :set-colorcolumn
       [[:BufReadPost :BufNew] {:pattern :* :command "set colorcolumn=78"}])

(ac.augroup :toggle-hlsearch
            [[:InsertEnter] {:pattern :* :command "set nohlsearch"}]
            [[:CmdlineEnter] {:pattern :? :command "set hlsearch"}]
            [[:CmdlineEnter] {:pattern :/ :command "set hlsearch"}])
; }}}
;; {{{ only display cursorline/cursorcolumn in current window
(ac.augroup :cursor-line
  [[:WinEnter] {:pattern :* :command "set cursorline"}]
  [[:WinLeave] {:pattern :* :command "set nocursorline"}]
  [[:WinLeave] {:pattern :* :command "set nocursorcolumn"}]) ; }}}
;; {{{ show listchars when not in insert mode
(ac.augroup :toggle-insert
  [[:InsertEnter] {:pattern :* :command "set nolist"}]
  [[:InsertLeave] {:pattern :* :command "set list"}]) ; }}}
;;; }}}

;; source machine-local config file
(vim.cmd "silent! source ~/.nvim.local.lua")

;; set default color-scheme (if it was not set in local config)
(let [colorscheme vim.g.colors_name]
  (when (or (= nil colorscheme) (= "default" colorscheme))
    (vim.cmd.colorscheme "habamax")))
