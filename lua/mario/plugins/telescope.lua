return {
    "nvim-telescope/telescope.nvim",
    -- Remove pinned version, use latest
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
                -- Add buffer validation
                cache_picker = {
                    num_pickers = 3,
                },
                mappings = {
                    i = {
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist
                    }
                },
                on_complete = {
                    function()
                    vim.schedule(function()
                        pcall(vim.api.nvim_buf_delete, 0, { force = true })
                    end)
                end
                },
            },
            pickers = {
                find_files = {
                    -- Disable problematic preview for now
                    previewer = false,
                },
            },
            extensions = {
                file_browser = {
                    path = "%:p:h",
                    display_stat = false,
                    grouped = true,
                    hidden = true,
                    hide_parent_dir = true,
                    hijack_netrw = true,
                    prompt_path = true,
                    use_fd = true
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
    end
}

