return {
    "nvim-telescope/telescope.nvim",
    branch = "master", -- track latest; without this lazy fell back to the 2024 0.1.8 tag
    dependencies = {
        "nvim-lua/plenary.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
            enabled = true
        },
        {"nvim-telescope/telescope-file-browser.nvim", enabled = true}
    },
    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")

        telescope.setup({
            defaults = {
                sorting_strategy = "ascending",
                layout_strategy = "horizontal",
                layout_config = {prompt_position = "top"},
                mappings = {
                    i = {
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist
                    }
                },
            },
            pickers = {
                find_files = {hidden = true, file_ignore_patterns = {"^.git/", "node_modules/", "dist/", "__pycache__/"}},
                live_grep = {additional_args = {"--hidden", "--glob", "!.git/"}},
            },
            extensions = {
                file_browser = {
                    path = "%:p:h",
                    display_stat = false,
                    grouped = true,
                    hidden = true,
                    hide_parent_dir = true,
                    -- nvim-tree owns directory buffers (`nvim .`); two hijackers race and crash
                    hijack_netrw = false,
                    prompt_path = true,
                    use_fd = vim.fn.executable("fd") == 1
                }
            }
        })

        telescope.load_extension("fzf")
        telescope.load_extension("file_browser")

        local builtin = require("telescope.builtin")

        local map = vim.keymap.set
        local opts = {noremap = true, silent = true}

        map("n", "-", ":Telescope file_browser<CR>")
        map("n", "<leader>ff", builtin.find_files, opts)
        map("n", "<leader>fx", builtin.treesitter, opts)
        map("n", "<leader>fs", builtin.spell_suggest, opts)
        map("n", "<leader>fg", builtin.live_grep, opts)
        map("n", "<leader>fb", builtin.buffers, opts)
        map("n", "<leader>fr", builtin.oldfiles, opts)
        map("n", "<leader>fd", builtin.diagnostics, opts)
        map("n", "<leader>fh", builtin.help_tags, opts)
        map("n", "gr", builtin.lsp_references, opts)
    end
}

