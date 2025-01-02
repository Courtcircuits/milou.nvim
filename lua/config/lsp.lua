local cmp = require('cmp')

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)   -- For `vsnip` users.
      -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      -- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),   -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' },   -- For vsnip users.
    -- { name = 'luasnip' }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    -- { name = 'snippy' }, -- For snippy users.
  }, {
    { name = 'buffer' },
  })
})

-- Reserve a space in the gutter
-- This will avoid an annoying layout shift in the screen
vim.opt.signcolumn = 'yes'

-- Add cmp_nvim_lsp capabilities settings to lspconfig
-- This should be executed before you configure any language server
local lspconfig_defaults = require('lspconfig').util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
  'force',
  lspconfig_defaults.capabilities,
  require('cmp_nvim_lsp').default_capabilities()
)


-- This is where you enable features that only work
-- if there is a language server active in the file
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local opts = { buffer = event.buf }

    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
    vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
    vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
    vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
    vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
    vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
    vim.keymap.set('n', '<leader>r', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
    vim.keymap.set({ 'n', 'x' }, '<leader>p', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
    vim.keymap.set('n', '<leader>vca', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
  end,
})

require('mason').setup({})
require('mason-lspconfig').setup({
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup({})
    end,
    lua_ls = function()
      require('lspconfig').lua_ls.setup({
        settings = {
          Lua = {
            telemetry = {
              enable = false
            },
          },
        },
        on_init = function(client)
          local join = vim.fs.joinpath
          local path = client.workspace_folders[1].name

          -- Don't do anything if there is project local config
          if vim.uv.fs_stat(join(path, '.luarc.json'))
              or vim.uv.fs_stat(join(path, '.luarc.jsonc'))
          then
            return
          end

          -- Apply neovim specific settings
          local runtime_path = vim.split(package.path, ';')
          table.insert(runtime_path, join('lua', '?.lua'))
          table.insert(runtime_path, join('lua', '?', 'init.lua'))

          local nvim_settings = {
            runtime = {
              -- Tell the language server which version of Lua you're using
              version = 'LuaJIT',
              path = runtime_path
            },
            diagnostics = {
              -- Get the language server to recognize the `vim` global
              globals = { 'vim' }
            },
            workspace = {
              checkThirdParty = false,
              library = {
                -- Make the server aware of Neovim runtime files
                vim.env.VIMRUNTIME,
                vim.fn.stdpath('config'),
              },
            },
          }

          client.config.settings.Lua = vim.tbl_deep_extend(
            'force',
            client.config.settings.Lua,
            nvim_settings
          )
        end,
      })
    end,
  },
})
