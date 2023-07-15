" {{{ settings
set textwidth=80
set foldmethod=indent

if has("nvim")
lua << EOF
  vim.g['conjure#extract#tree_sitter#enabled'] = true
EOF
endif
" }}}
" {{{ mappings
" }}}
