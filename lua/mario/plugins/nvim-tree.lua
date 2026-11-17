return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  init = function()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end,
  config = function()
    require("nvim-tree").setup({
      hijack_netrw = true,
      hijack_directories = { enable = true, auto_open = true },
      sync_root_with_cwd = true,
      update_focused_file = { enable = true },
      filters = { dotfiles = false, custom = { "^.git$", "^__pycache__$" } },
      git = { ignore = false }, -- show .env, dist etc. (greyed) instead of hiding them
      view = {
        width = 30,
        side = "left",
      },
    })

    -- Toggle with Shift+b
    vim.keymap.set("n", "<S-b>", ":NvimTreeToggle<CR>", { silent = true })
  end,
}
