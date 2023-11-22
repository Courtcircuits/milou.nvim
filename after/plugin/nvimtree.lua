-- write a configuration file for the plugin

require('nvim-tree').setup{
  disable_netrw = true,
  hijack_netrw = true,
  view = {
    width = 27,
    number = true,
  },
}
