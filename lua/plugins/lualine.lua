return {
{
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = function()
      require("config.lualine")
    end
}
}
