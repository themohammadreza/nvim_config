return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { 
        "lua", 
        "python", 
        "rust",
        "javascript",
        "typescript",
        "json",
        "yaml",
        "bash"
        -- Don't include "go" here
      },
      
      sync_install = false,
      auto_install = false,  -- Set to false to prevent auto-installing missing parsers
      
      highlight = {
        enable = true,
        disable = { "go" },  -- Explicitly disable Go
        additional_vim_regex_highlighting = { "go" },  -- Use vim regex for Go instead
      },
      
      indent = {
        enable = true,
        disable = { "go" },
      },
    })
  end,
}