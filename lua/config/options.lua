vim.opt.nu = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.wildignore:append({ "*/node_modules/*" })

vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true
vim.opt.clipboard = "unnamedplus"

vim.opt.termguicolors = true
vim.o.wrap = true
vim.wo.relativenumber = true
