vim.keymap.set("n", "<leader>pc", ":Oil <CR>")

vim.keymap.set("n", "<leader>p", vim.lsp.buf.format)

vim.keymap.set('n', '<S-x>', vim.diagnostic.open_float)
vim.keymap.set('n', '<S-k>', vim.lsp.buf.hover)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration)
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation)
vim.keymap.set('n', 'go', vim.lsp.buf.type_definition)
vim.keymap.set('n', 'gr', vim.lsp.buf.references)
vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help)
vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename)
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action)


local builtin = require('telescope.builtin')
vim.keymap.set("n", "<leader>pf", builtin.find_files)
vim.keymap.set("n", "<leader>ps", builtin.live_grep)
vim.keymap.set("n", "<leader>pe", builtin.diagnostics)

vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')


function insertFullPath()
  local filepath = vim.fn.expand('%')
  vim.fn.setreg('+', filepath) -- write to clippoard
end

vim.keymap.set('n', '<leader>y', insertFullPath, { noremap = true, silent = true })

function insertFilePathWithLines()
  local filepath = vim.fn.expand('%')
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  local result = filepath .. '#L' .. start_line .. '-L' .. end_line
  vim.fn.setreg('+', result)
end

vim.keymap.set('v', '<leader>y', insertFilePathWithLines, { noremap = true, silent = true })
