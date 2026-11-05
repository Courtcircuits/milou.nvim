vim.pack.add({
		{ src = "https://github.com/esmuellert/codediff.nvim" },
		{ src = "https://gitlab.com/gitlab-org/editor-extensions/gitlab.vim" }
})

require("config.pairwork")
require("config.gitlab")
