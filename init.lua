if vim.loader then
	vim.loader.enable()
end

require("config.lazy")
require("config.keymaps")
require("config.options")
