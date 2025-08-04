require("oil").setup({
	keymaps = {
				["<CR>"] = "actions.select",
				["-"] = "actions.parent",
				["<Esc>"] = "actions.close",
			}
})
