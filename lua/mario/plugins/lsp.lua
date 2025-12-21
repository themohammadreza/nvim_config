return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      
      vim.diagnostic.config({
        virtual_text = {
          severity = { min = vim.diagnostic.severity.WARN },
          source = "if_many",
          prefix = "●",
        },
        signs = true,
        update_in_insert = false,
        underline = true,
        severity_sort = true,
        float = {
          border = "rounded",
          source = "always",
        },
      })
      
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { 
          "rust_analyzer",
          "basedpyright",
          "ruff",
          "gopls",
          "clangd",
        }
      })
      
      -- Rust
      vim.lsp.config('rust_analyzer', {
        capabilities = capabilities,
        settings = {
          ['rust-analyzer'] = {
            check = { command = "clippy" },
            inlayHints = {
              chainingHints = { enable = false },
              parameterHints = { enable = false },
              typeHints = { enable = true },
            },
          },
        },
      })
      vim.lsp.enable('rust_analyzer')
      
      -- Python
      vim.lsp.config('basedpyright', {
        capabilities = capabilities,
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "standard",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
      })
      vim.lsp.enable('basedpyright')
      
      vim.lsp.config('ruff', { capabilities = capabilities })
      vim.lsp.enable('ruff')
      
      -- Go
      vim.lsp.config('gopls', {
        capabilities = capabilities,
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
              shadow = true,
            },
            staticcheck = true,
            gofumpt = true,
          },
        },
      })
      vim.lsp.enable('gopls')
      
      -- C++
      vim.lsp.config('clangd', {
        cmd = { 
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
        },
        capabilities = capabilities,
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
        },
      })
      vim.lsp.enable('clangd')
    end,
  },
}

