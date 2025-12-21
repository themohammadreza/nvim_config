return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("nvim-tree").setup({
      view = {
        width = 30,
        side = "left",
      },
    })

    -- Toggle with Shift+b
    vim.keymap.set("n", "<S-b>", ":NvimTreeToggle<CR>", { silent = true })
  end,
}
