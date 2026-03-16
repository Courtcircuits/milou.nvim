vim.lsp.enable({
	"lua_ls",
	"solargraph",
	"pyright",
	"ts_ls",
	"rubocop",
	"ruby-lsp",
	"rust_analyzer",
	"tailwindcss",
	"cssls",
	"clangd",
	"tinymist",
	"gopls",
	"basedpyright",
	"tofu_ls",
	"kotlin_lsp"
})

require('lspconfig').gleam.setup({})

require('lspconfig').rust_analyzer.setup({
	settings = {

		["rust-analyzer"] = {
			check = {
				command = "clippy",
			}
		}
	}
})
