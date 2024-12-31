local telescope = require("telescope.builtin")

vim.g.mapleader = " "
vim.keymap.set("n", "<C-Up>", "5k")
vim.keymap.set("n", "<C-Down>", "5j")
vim.keymap.set("i", "<C-BS>", "<C-W>")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- vim.keymap.del("n", "<C-h>")
-- vim.keymap.del("n", "<C-k>")
-- vim.keymap.del("n", "<C-j>")
-- vim.keymap.del("n", "<C-l>")
--
-- vim.keymap.set("n", "<C-h>", function()
-- 	harpoon:list():select(1)
-- end)
-- vim.keymap.set("n", "<C-j>", function()
-- 	harpoon:list():select(2)
-- end)
-- vim.keymap.set("n", "<C-k>", function()
-- 	harpoon:list():select(3)
-- end)
-- vim.keymap.set("n", "<C-l>", function()
-- 	harpoon:list():select(4)
-- end)
--
-- vim.keymap.set("n", "<leader>pc", require("oil").open, { desc = "Open parent directory" })
-- when in oil, cd .. with <C-Left>
--
