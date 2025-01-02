return {
{
		"stevearc/oil.nvim",
		opts = {
			keymaps = {
				["<CR>"] = "actions.select",
				["-"] = "actions.parent",
				["<Esc>"] = "actions.close",
			},
		},
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		keys = {
			{
				"<leader>pc",
				function()
					require("oil").open_float()
				end,
			},
		},
	},
}
