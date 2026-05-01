
require("lume").setup({
  transparent = true, -- set to true to use your terminal's background
  italics = true,      -- set to false to disable italic comments/keywords
  palette_overrides = { -- override base palette colors before they cascade to all groups
    foregrounds = { text = "#c8c8d8" },   -- softer foreground
    accents = { lavender = "#DB4E6C" },   -- tweak any accent
  },
})
vim.cmd("colorscheme lume")
