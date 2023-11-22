vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", ":NvimTreeToggle<CR>")
vim.keymap.set("n", "<C-Up>", "5k")
vim.keymap.set("n", "<C-Down>", "5j")
vim.keymap.set("i", "<C-BS>", "<C-W>")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<leader>pc", require("oil").open, { desc = "Open parent directory" })
-- when in oil, cd .. with <C-Left>
