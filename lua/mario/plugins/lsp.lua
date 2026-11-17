-- Resolve the Python interpreter for a project root, in this order:
-- 1. an activated venv / conda env ($VIRTUAL_ENV, $CONDA_PREFIX other than base)
-- 2. a local .venv / venv folder in the project
-- 3. the conda env named in the project's environment.yml (e.g. te-hrms -> `hrms`)
-- 4. whatever `python` is on PATH
local function python_for(root)
  local function exe(p) return p and vim.fn.executable(p) == 1 and p or nil end
  local venv = os.getenv("VIRTUAL_ENV")
  if venv and exe(venv .. "/bin/python") then return venv .. "/bin/python" end
  local conda = os.getenv("CONDA_PREFIX")
  if conda and os.getenv("CONDA_DEFAULT_ENV") ~= "base" and exe(conda .. "/bin/python") then
    return conda .. "/bin/python"
  end
  if root then
    for _, d in ipairs({ ".venv", "venv" }) do
      local p = exe(root .. "/" .. d .. "/bin/python")
      if p then return p end
    end
    local envfile = root .. "/environment.yml"
    if vim.fn.filereadable(envfile) == 1 then
      for _, line in ipairs(vim.fn.readfile(envfile, "", 20)) do
        local name = line:match("^name:%s*([%w%-_%.]+)")
        if name then
          for _, base in ipairs({ "~/miniconda3", "~/anaconda3", "~/miniforge3" }) do
            local p = exe(vim.fn.expand(base) .. "/envs/" .. name .. "/bin/python")
            if p then return p end
          end
        end
      end
    end
  end
  return exe(vim.fn.exepath("python3")) or vim.fn.exepath("python")
end

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

      -- Applies to every server below
      vim.lsp.config("*", { capabilities = capabilities })

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
        float = { border = "rounded", source = true },
      })

      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "pyright",
          "ruff",
          "ts_ls",
          "lua_ls",
          "bashls",
          "rust_analyzer",
          "gopls",
          "clangd",
        },
        automatic_enable = false, -- servers are enabled explicitly below
      })

      -- Python (te-hrms/Django): use the project's env, not base conda
      vim.lsp.config("pyright", {
        before_init = function(_, config)
          config.settings = config.settings or {}
          config.settings.python = vim.tbl_deep_extend("force", config.settings.python or {}, {
            pythonPath = python_for(config.root_dir),
          })
        end,
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "standard",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "openFilesOnly", -- "workspace" also crawls node_modules/dist
            },
          },
        },
      })
      vim.lsp.enable({ "pyright", "ruff" })

      -- TypeScript / React. TypeScript 7 (te-hrms frontend) has no tsserver.js and ships its own
      -- LSP (`tsc --lsp --stdio`), so TS 7 projects get that; everything else gets ts_ls.
      local function ts_root(bufnr)
        return vim.fs.root(bufnr, { "tsconfig.json", "jsconfig.json", "package.json" })
      end
      local function ts7_bin(root)
        local pkg = root and root .. "/node_modules/typescript/package.json"
        if not (pkg and vim.fn.filereadable(pkg) == 1) then return nil end
        local ok, data = pcall(vim.json.decode, table.concat(vim.fn.readfile(pkg), "\n"))
        local major = ok and tonumber(tostring(data.version):match("^(%d+)")) or 0
        local bin = root .. "/node_modules/.bin/tsc"
        return major >= 7 and vim.fn.executable(bin) == 1 and bin or nil
      end
      vim.lsp.config("tsgo", {
        cmd = function(dispatchers, config)
          return vim.lsp.rpc.start({ ts7_bin(config.root_dir), "--lsp", "--stdio" }, dispatchers,
            { cwd = config.root_dir })
        end,
        root_dir = function(bufnr, on_dir)
          local root = ts_root(bufnr)
          if ts7_bin(root) then on_dir(root) end
        end,
      })
      vim.lsp.config("ts_ls", {
        root_dir = function(bufnr, on_dir)
          local root = ts_root(bufnr)
          if root and not ts7_bin(root) then on_dir(root) end
        end,
      })
      vim.lsp.enable({ "tsgo", "ts_ls" })

      -- Lua (this config)
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
            telemetry = { enable = false },
          },
        },
      })
      vim.lsp.enable("lua_ls")

      -- Shell scripts
      vim.lsp.enable("bashls")

      -- Rust
      vim.lsp.config("rust_analyzer", {
        settings = {
          ["rust-analyzer"] = {
            check = { command = "clippy" },
            inlayHints = {
              chainingHints = { enable = false },
              parameterHints = { enable = false },
              typeHints = { enable = true },
            },
          },
        },
      })
      vim.lsp.enable("rust_analyzer")

      -- Go
      vim.lsp.config("gopls", {
        settings = {
          gopls = {
            analyses = { unusedparams = true, shadow = true },
            staticcheck = true,
            gofumpt = true,
          },
        },
      })
      vim.lsp.enable("gopls")

      -- C/C++
      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
        },
        init_options = { usePlaceholders = true, completeUnimported = true },
      })
      vim.lsp.enable("clangd")

      -- Buffer-local LSP keymaps
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          -- Keep treesitter colours: turn off LSP semantic highlighting. (Sending
          -- semanticTokens = null in capabilities breaks strict servers like TS 7's.)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client then client.server_capabilities.semanticTokensProvider = nil end
          local o = { buffer = ev.buf, silent = true }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, o)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, o)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, o)
          vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, o)
          vim.keymap.set("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, o)
          vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, o)
          vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, o)
          vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, o)
        end,
      })
    end,
  },
}
