return {
	{
		"williamboman/mason.nvim",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, {
				"stylua",
				"selene",
				"luacheck",
				"shellcheck",
				"shfmt",
				"tailwindcss-language-server",
				"typescript-language-server",
				"css-lsp",
				"rust-analyzer",
			})
		end,
	},
	{
		"vonheikemen/lsp-zero.nvim",
		dependencies = {
			"neovim/nvim-lspconfig",
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-nvim-lsp",
			"l3mon4d3/luasnip",
		},
		opts = function()
			require("config.lsp")
		end,
	},
}
