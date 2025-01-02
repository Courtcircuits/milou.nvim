return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    {
      "<leader>pf",
      function()
        require("telescope.builtin").find_files()
      end,
    },
    {
      "<leader>ps",
      function()
        require("telescope.builtin").live_grep()
      end,
    },
    {
      "<leader>pe",
      function()
        require("telescope.builtin").diagnostics()
      end,
    }
  }
}
