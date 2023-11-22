local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pf', function()
  builtin.find_files({ no_ignore_vcs = true });
end, {})
vim.keymap.set('n', '<C-n>', builtin.git_files, {})
vim.keymap.set('n', '<leader>ps', function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)
