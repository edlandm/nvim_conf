vim.wo.conceallevel = 2
vim.wo.wrap = false
vim.wo.concealcursor = 'nc'

---cd to the :PWD: property of the given org file (if set)
local function org_cd_to_pwd()
  local path = vim.fn.expand('%:p')
  local pwd = org.file_get_property(path, 'pwd')

  if not pwd or vim.trim(pwd) == '' then
    print('org-mode :: No :PWD: Property set')
    return
  end

  vim.cmd({ cmd = 'cd', args = { vim.fn.expand(pwd) } })
  print('cd -> ' .. pwd)
end

---create hard link from current file to :PWD:/index.org
local function org_link_to_pwd()
  local path = vim.fn.expand('%:p')
  local pwd = org.file_get_property(path, 'pwd')
  if not (pwd and vim.fn.isdirectory(vim.fn.expand(pwd)) == 1) then
    return
  end

  local index_file = vim.fs.joinpath(vim.fn.expand(pwd), 'index.org')
  if vim.uv.fs_stat(index_file) then
    print(('Org-Mode :: %s already exists'):format(index_file))
    return
  end

  local on_exit = function(obj)
    print(obj.code)
    print(obj.signal)
    print(obj.stdout)
    print(obj.stderr)
  end

  vim.system({ 'ln', path, index_file }, {}, on_exit):wait()
  print(('Org-Mode :: Linked %s -> %s'):format(path, index_file))
end

vim.api.nvim_buf_create_user_command(0, 'OrgLinkToPWD', org_link_to_pwd, {
  desc     = 'Link file to :PWD:/index.org',
})

vim.api.nvim_buf_set_keymap(0, 'n', '<localleader>.', '', {
  desc = 'ORG: CD to :PWD:',
  callback = org_cd_to_pwd,
})
