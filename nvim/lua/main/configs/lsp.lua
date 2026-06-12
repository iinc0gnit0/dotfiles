require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "rust_analyzer",
    "pyright",
    "clangd",
    "ts_ls",
    "eslint",
    "terraformls",
  },
  automatic_installation = true,
})

-- Completion setup
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    {
      name = 'nvim_lsp',
      entry_filter = function(entry, ctx)
        return require("cmp").lsp.CompletionItemKind.Text ~= entry:get_kind()
      end
    },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  })
})

-- LSP capabilities for autocompletion
--local capabilities = require('cmp_nvim_lsp').default_capabilities()
local capabilities = vim.lsp.protocol.make_client_capabilities() -- Get The capabilities
capabilities.general.positionEncodings = { "utf-16" } -- Set the offset encoding, see `:h vim.lsp.start` for more info
vim.lsp.config('server', { capabilities = capabilities }) -- Setup the server

-- LSP keybindings
local on_attach = function(client, bufnr)
  local opts = { buffer = bufnr, noremap = true, silent = true }

  -- Keybindings
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format({ async = true }) end, opts)
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
  vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)
end

-- Configure diagnostics
vim.diagnostic.config({
  virtual_lines = {
    current_line = true,
  },
  signs = true,
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  float = {
    border = 'rounded',
    source = 'always',
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "✘",
      [vim.diagnostic.severity.WARN] = "▲",
      [vim.diagnostic.severity.HINT] = "⚑",
      [vim.diagnostic.severity.INFO] = "»",
    },
  }
})

-- Rust
vim.lsp.config('rust_analyzer', {
  settings = {
    ['rust-analyzer'] = {
      cargo = {
        allFeatures = true,
      },
      checkOnSave = true,
      check = {
        command = "clippy",
      },
    },
  },
})

-- Python
vim.lsp.config('pyright', {
  on_attach = on_attach,
  capabilities = capabilities,
})

-- C/C++
vim.lsp.config('clangd', {
  on_attach = on_attach,
  capabilities = capabilities,
})

-- TypeScript/JavaScript
vim.lsp.config('ts_ls', {
  on_attach = on_attach,
  capabilities = capabilities,
})

-- ESLint
vim.lsp.config('eslint', {
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)
    -- Auto-fix on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "EslintFixAll",
    })
  end,
  capabilities = capabilities,
})

-- Terraform
vim.lsp.config('terraformls', {
  on_attach = on_attach,
  capabilities = capabilities,
})

require("conform").setup({
  formatters_by_ft = {
    ["*"] = { "trim_whitespace", "trim_newlines" },
    rust = { "rustfmt" },
    python = { "black" },
    javascript = { "prettierd", "eslint_d" },
    javascriptreact = { "prettierd", "eslint_d" },
    typescript = { "prettierd", "eslint_d" },
    typescriptreact = { "prettierd", "eslint_d" },
    cpp = { "clang-format" },
    c = { "clang-format" },
    terraform = { "terraform_fmt" },
    typest = { "typstyle" },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
})

-- Also format on save for all files
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    require("conform").format({ bufnr = args.buf })
  end,
})
