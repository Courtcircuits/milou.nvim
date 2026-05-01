vim.opt.number = true

vim.opt.relativenumber = true
vim.opt.swapfile = false
vim.g.mapleader = " "
vim.opt.signcolumn = "yes"
vim.opt.tabstop = 4

vim.pack.add({
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/rose-pine/neovim" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
	{ src = 'https://github.com/hrsh7th/cmp-nvim-lsp' },
	{ src = 'https://github.com/hrsh7th/cmp-buffer' },
	{ src = 'https://github.com/hrsh7th/cmp-path' },
	{ src = 'https://github.com/hrsh7th/cmp-cmdline' },
	{ src = 'https://github.com/hrsh7th/nvim-cmp' },
	{ src = 'https://github.com/hrsh7th/cmp-vsnip' },
	{ src = 'https://github.com/hrsh7th/vim-vsnip' },
	{ src = 'https://github.com/nvim-lua/plenary.nvim' },
	{ src = 'https://github.com/ThePrimeagen/harpoon',            version = 'harpoon2' },
	{ src = 'https://github.com/nvim-lualine/lualine.nvim' },
	{ src = "https://github.com/tpope/vim-fugitive" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	{ src = "https://github.com/sindrets/diffview.nvim" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons.git" },
	{ src = "https://github.com/benomahony/uv.nvim" },
	{ src = "https://github.com/m4xshen/autoclose.nvim" },
	{ src = "https://github.com/sylvanfranklin/omni-preview.nvim" },
	{ src = "https://github.com/chomosuke/typst-preview.nvim" },
	{ src = "https://github.com/saliola/vim-sage" },
	{ src = "https://github.com/ldelossa/litee.nvim" },
	{ src = "https://github.com/ldelossa/gh.nvim" },
	{ src = "https://github.com/img-paste-devs/img-paste.vim"},
	{ src = "https://github.com/MunifTanjim/nui.nvim"},
	{ src = "https://github.com/giusgad/hologram.nvim"},
	{ src = "https://github.com/giusgad/pets.nvim" }, -- really important
	{ src = "https://github.com/github/copilot.vim" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/danfry1/lume"}
})


require("config.oil")
require("config.lsp")
require("config.cmp")
require("config.pick")
require("config.harpoon")
require("config.lualine")
require("config.git")
require("config.uv")
require("config.keymaps")
require("config.treesitter")
require("config.autoclose")
require("config.copilot")
require("config.preview")
require("config.gh")
require("config.imgpaste")
require("config.pets")
require("config.colorscheme")

