local alpha = require'alpha'
local startify = require'alpha.themes.startify'
startify.section.top_buttons.val = {
    startify.button( "e", "  New file" , ":ene <BAR> startinsert <CR>"),
}
-- disable MRU
startify.section.mru.val = { { type = "padding", val = 0 } }
startify.section.bottom_buttons.val = {
    startify.button( "q", "  Quit NVIM" , ":qa<CR>"),
}
startify.section.footer = {
    { type = "text", val = "footer" },
}
alpha.setup(startify.config)


local gknapsettings = {
    texoutputext = "pdf",
    textopdf = "latexmk -pdf -pdflatex='lualatex -synctex=1 -halt-on-error -interaction=batchmode' %docroot%",
}
vim.g.knap_settings = gknapsettings
local kmap = vim.keymap.set
kmap('n','<F7>', function() require("knap").toggle_autopreviewing() end)
kmap('i','<F8>', function() require("knap").forward_jump() end)
kmap('v','<F8>', function() require("knap").forward_jump() end)
kmap('n','<F8>', function() require("knap").forward_jump() end)

-- DAP

local dap = require('dap')
dap.adapters.lldb = {
  type = 'executable',
  command = 'lldb-vscode',
  name = "lldb",
}
dap.configurations.cpp = {
  {
    name = 'Launch',
    type = 'lldb',
    request = 'launch',
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = "''${workspaceFolder}",
    stopOnEntry = false,
    args = {},
    runInTerminal = false,
  },
}
dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

require('lspsaga').setup({
  symbol_in_winbar = {
    enable = false,
  },
})

-- setup
vim.lsp.handlers['window/showMessage'] = function(_, result, ctx)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  local lvl = ({ 'ERROR', 'WARN', 'INFO', 'DEBUG' })[result.type]
  vim.notify(result.message, lvl, {
    title = 'LSP | ' .. client.name,
    timeout = 10000,
  })
end

vim.cmd [[autocmd! ColorScheme * highlight NormalFloat guibg=#1f2335]]
vim.cmd [[autocmd! ColorScheme * highlight FloatBorder guifg=white guibg=#1f2335]]

local border = {
      {"🭽", "FloatBorder"},
      {"▔", "FloatBorder"},
      {"🭾", "FloatBorder"},
      {"▕", "FloatBorder"},
      {"🭿", "FloatBorder"},
      {"▁", "FloatBorder"},
      {"🭼", "FloatBorder"},
      {"▏", "FloatBorder"},
}

-- LSP settings (for overriding per client)
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {border = border})
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {border = border })

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Diagnostic keymaps
vim.api.nvim_set_keymap('n', '<leader>e', '<cmd>Telescope diagnostics<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '[d', '<cmd>Lspsaga diagnostic_jump_prev<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', ']d', '<cmd>Lspsaga diagnostic_jump_next<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', { noremap = true, silent = true })

-- LSP settings
local lspconfig = require 'lspconfig'
local on_attach = function(client, bufnr)
  local opts = { noremap = true, silent = true }
  local map = vim.api.nvim_buf_set_keymap
  map(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  map(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  map(bufnr, "n", "K",  '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  map(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  map(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  map(bufnr, 'n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  map(bufnr, 'n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  map(bufnr, 'n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  map(bufnr, "n", "<leader>cr", "<cmd>Lspsaga rename<cr>", opts)
  map(bufnr, 'n', 'gr', '<cmd>Telescope lsp_references<CR>', opts)
  map(bufnr, 'n', '<leader>ca', '<cmd>Lspsaga code_action<CR>', opts)
  map(bufnr, 'x', '<leader>ca', '<cmd>Lspsaga range_code_action<CR>', opts)
  map(bufnr, 'n', '<leader>so', [[<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>]], opts)

  -- Enable inlay hints if the client supports it.
  -- if client.server_capabilities.inlayHintProvider then
  --   vim.lsp.inlay_hint.enable(true)
  -- end
end

-- nvim-cmp supports additional completion capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
require('cmp_nvim_lsp').default_capabilities = capabilities

-- Enable the following language server
local servers = { 'clangd', 'pyright', 'ts_ls', 'texlab', 'hls', 'nil_ls', 'rust_analyzer', 'jdtls' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

lspconfig['tinymist'].setup {
  on_attach = on_attach,
  capabilities = capabilities,
  offset_encoding = "utf-8",
}

-- nvim-cmp setup

local kind_icons = {
  Text = "",
  Method = "",
  Function = "",
  Constructor = "",
  Field = "",
  Variable = "",
  Class = "ﴯ",
  Interface = "",
  Module = "",
  Property = "ﰠ",
  Unit = "",
  Value = "",
  Enum = "",
  Keyword = "",
  Snippet = "",
  Color = "",
  File = "",
  Reference = "",
  Folder = "",
  EnumMember = "",
  Constant = "",
  Struct = "",
  Event = "",
  Operator = "",
  TypeParameter = ""
}

local cmp = require 'cmp'
cmp.setup {
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end,
  },
  sources = {
    { name = "copilot" },
    { name = 'nvim_lsp' },
    { name = 'path' },
    { name = 'buffer' },
    { name = 'latex_symbols' }
  },
  formatting = {
    format = function(entry, vim_item)
      local kind = require("lspkind").cmp_format({
        mode = "symbol_text",
        maxwidth = 50
      })(entry, vim_item)
      local menu = ({
        buffer = "[Buffer]",
        nvim_lsp = "[LSP]",
        path = "[Path]",
        latex_symbols = "[LaTeX]",
        copilot = "[copilot]"
      })[entry.source.name]
      local strings = vim.split(kind.kind, "%s", { trimempty = true })
      kind.kind = " " .. strings[1] .. " "
      kind.menu = "    (" .. menu .. ")"
      return kind
    end,
  },
  sorting = {
    priority_weight = 2,
    comparators = {
      -- Below is the default comparitor list and order for nvim-cmp
      cmp.config.compare.offset,
      -- cmp.config.compare.scopes, --this is commented in nvim-cmp too
      cmp.config.compare.exact,
      cmp.config.compare.score,
      cmp.config.compare.recently_used,
      cmp.config.compare.locality,
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },
}

local map = vim.keymap.set
local dap, dapui = require("dap"), require("dapui")

dapui.setup()
dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
  dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  dapui.close()
end

require "lsp_signature".setup({})

dap.adapters.gdb = {
  type = "executable",
  command = "gdb",
  args = { "-i", "dap" }
}
dap.configurations.c = {
  {
    name = "Launch",
    type = "gdb",
    request = "launch",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = "${workspaceFolder}",
    stopAtBeginningOfMainSubprogram = false,
  },
}
dap.configurations.cpp = dap.configurations.c
dap.configurations.rust = dap.configurations.c
