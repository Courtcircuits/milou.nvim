return {
	{
		"goolord/alpha-nvim",
		event = "VimEnter",
		enabled = true,
		init = false,
		opts = function()
			local dashboard = require("alpha.themes.dashboard")
			local logo = [[
  __      _
o'')}____//
 `_/      )
 (_(_/-(_/ hello !
    ]]

			dashboard.section.header.val = vim.split(logo, "\n")
      -- stylua: ignore
      dashboard.section.buttons.val = {
        dashboard.button("f", " " .. " Find file", "<cmd> Telescope find_files <cr>"),
        dashboard.button("n", " " .. " New file", "<cmd> ene <BAR> startinsert <cr>"),
        dashboard.button("r", " " .. " Recent files", "<cmd> Telescope oldfiles <cr>"),
        dashboard.button("g", " " .. " Find text", "<cmd> Telescope live_grep <cr>"),
        dashboard.button("c", "" .. "  Config", "<cmd> lua require('lazyvim.util').telescope.config_files()() <cr>"),
        dashboard.button("s", "" .. "  Restore Session", [[<cmd> lua require("persistence").load() <cr>]]),
        dashboard.button("q", "󰩈 " .. " Quit", "<cmd> qa <cr>"),
      }
			for _, button in ipairs(dashboard.section.buttons.val) do
				button.opts.hl = "AlphaButtons"
				button.opts.hl_shortcut = "AlphaShortcut"
			end
			dashboard.section.header.opts.hl = "AlphaHeader"
			dashboard.section.buttons.opts.hl = "AlphaButtons"
			dashboard.section.footer.opts.hl = "AlphaFooter"
			dashboard.opts.layout[1].val = 8
			return dashboard
		end,
		config = function(_, dashboard)
			-- close Lazy and re-open when the dashboard is ready
			if vim.o.filetype == "lazy" then
				vim.cmd.close()
				vim.api.nvim_create_autocmd("User", {
					once = true,
					pattern = "AlphaReady",
					callback = function()
						require("lazy").show()
					end,
				})
			end

			require("alpha").setup(dashboard.opts)
		end,
	},
	{
		"telescope.nvim",
		dependencies = {
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
			},
			"nvim-telescope/telescope-file-browser.nvim",
		},
		keys = {
			{
				"<leader>pe",
				function()
					require("telescope.builtin").diagnostics()
				end,
			},
			{
				"<leader>pf",
				function()
					require("telescope.builtin").find_files({
						no_ignore_vcs = true,
					})
				end,
				desc = "Find files",
			},
			{
				"<leader>ps",
				function()
					require("telescope.builtin").live_grep()
				end,
				desc = "Find words in a project",
			},
		},
	},
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
					require("oil").open()
				end,
			},
		},
	},
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = function()
			require("config.harpoon")
		end,
		keys = {
			{
				"<leader>a",
				function()
					require("harpoon"):list():add()
				end,
				desc = "harpoon file",
			},
			{
				"<C-h>",
				function()
					require("harpoon"):list():select(1)
				end,
				desc = "harpoon to file 1",
			},
			{
				"<C-j>",
				function()
					require("harpoon"):list():select(2)
				end,
				desc = "harpoon to file 2",
			},
			{
				"<C-k>3",
				function()
					require("harpoon"):list():select(3)
				end,
				desc = "harpoon to file 3",
			},
			{
				"<C-l>4",
				function()
					require("harpoon"):list():select(4)
				end,
				desc = "harpoon to file 4",
			},
			{
				"<C-e>",
				function()
					local harpoon = require("harpoon")
					harpoon.ui:toggle_quick_menu(harpoon:list())
				end,
			},
		},
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
			-- "3rd/image.nvim", -- Optional
		},
		keys = {
			{
				"<leader>pv",
				function()
					return vim.cmd("Neotree right")
				end,
			},
		},
	},
}
