return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = true,
		opts = function()
			require("config.toggleterm")
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
			vim.cmd("Gitsigns toggle_current_line_blame")
		end,
	},
	{
		"tpope/vim-fugitive",
	},
}
