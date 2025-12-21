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

		-- Configure how diagnostics are displayed
      vim.diagnostic.config({
		  virtual_text = {
          severity = { min = vim.diagnostic.severity.WARN },  -- Only show warnings and errors
          source = "if_many",  -- Only show source if multiple sources
          prefix = "●",  -- Simple prefix instead of full text
				},
        signs = true,         -- Show signs in the gutter (left side)
        update_in_insert = false,
        underline = true,
        severity_sort = true,
        float = {
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })
      
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "rust_analyzer" }
      })
      
      -- Configure rust-analyzer
      vim.lsp.config('rust_analyzer', {
        capabilities = capabilities,
        settings = {
				['rust-analyzer'] = {
            check = {
              command = "clippy",
            },
            inlayHints = {
              enable = true,
              chainingHints = { enable = false },  -- Disable chaining hints
              parameterHints = { enable = false },  -- Disable parameter hints
              typeHints = { enable = true },  -- Keep type hints
            },
          },
        },
      })
      
      vim.lsp.enable('rust_analyzer')
    end,
  },
}
