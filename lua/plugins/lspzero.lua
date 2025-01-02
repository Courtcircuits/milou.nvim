return {
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
