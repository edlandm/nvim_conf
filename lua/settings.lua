---set vim options
---@param namespace ('o' | 'bo' | 'g' | 'wo' | 'env')?
---@param options (string | [string, any)[]]
local function setopts(namespace, options)
  local ns = namespace or 'o'
  for _, opt in ipairs(options) do
    if type(opt) == 'string' then
      vim[ns][opt] = true
    else
      vim[ns][opt[1]] = opt[2]
    end
  end
end

setopts(nil, {
  'cursorline',
  'expandtab',
  'ignorecase',
  'list',
  'number',
  'relativenumber',
  'shiftround',
  'smartcase',
  'splitbelow',
  'splitright',
  'termguicolors',
  'wildignorecase',
  'wrap',
  { 'cdpath',         '~/,.,./*' },
  { 'completeopt',    'longest,menuone,preview' },
  { 'diffopt',        'filler,vertical,iwhite,hiddenoff' },
  { 'display',        'lastline,uhex' },
  { 'equalalways',    false },
  { 'fileencodings',  'utf-8,default,latin1' },
  { 'foldopen',       'insert,percent,quickfix,tag,undo,mark' },
  { 'foldlevelstart', 1 },
  { 'fillchars',      'fold: ' },
  { 'formatoptions',  'tcq1nb' },
  { 'grepprg',        'rg --vimgrep $*' },
  { 'helplang',       'en' },
  { 'inccommand',     'split', },
  { 'lcs',            'tab:¦ ,trail:·' },
  { 'maxmapdepth',    20 },
  { 'nrformats',      'hex' },
  { 'omnifunc',       'syntaxcomplete#Complete' },
  { 'path',           '~/,.' },
  { 'pumheight',      15 },
  { 'scrolloff',      3 },
  { 'sessionoptions', 'blank,buffers,curdir,options,localoptions,tabpages,winsize,' },
  { 'shelltemp',      false },
  { 'shiftwidth',     4 },
  { 'shortmess',     'ltToOCF' },
  { 'suffixes',       '.bak,~,.o,.h,.info,.swp,.obj,.pyc' },
  { 'suffixesadd',    'txt,html,md,sh' },
  { 'swapfile',       false },
  { 'switchbuf',      'useopen' },
  { 'synmaxcol',      500 },
  { 'tabpagemax',     5 },
  { 'tabstop',        4 },
  { 'tags',           './tags,tags,./.tags' },
  { 'termsync',       false },
  { 'textwidth',      78 },
  { 'title',          false },
  { 'titleold',       '' },
  { 'viewoptions',    'cursor' },
  { 'wildignore',     '.hg,.git,.svn,*.aux,*.out,*.toc,*.jpg,*.bmp,*.gif,*.png,*.jpeg,*.o,*.obj,*.exe,*.dll,*.manifest,#.spl,#.sw?,#.DS_Store,#.pyc' },
  { 'wildmode',       'list:longest' },
})

setopts('g', { -- Global Variables
  'omni_sql_no_default_maps',
  'html_dynamic_folds',
  'fnl_loaded',
  { 'aniseed#env', true },
  { 'netrw_browsex_viewer', 'xdg-open' },
})

return {
  setopts = setopts,
}
