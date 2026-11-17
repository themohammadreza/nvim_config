vim.g.mapleader = " "

vim.opt.encoding = "utf-8"

vim.opt.compatible = false
vim.opt.hlsearch = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.laststatus = 2
vim.opt.vb = true
vim.opt.ruler = true
vim.opt.number = true
vim.opt.spell = false -- en_us spell flags every Persian word; enabled per-filetype below
vim.opt.spelllang = "en_us"
vim.opt.spelloptions = "camel"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 300
vim.opt.undofile = true
vim.opt.scrolloff = 5
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.termbidi = true -- let the terminal handle Persian/RTL shaping
vim.opt.autoindent = true
vim.opt.colorcolumn = "120"
vim.opt.textwidth = 120
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.scrollbind = false
vim.opt.wildmenu = true

vim.opt.tabstop = 3
vim.opt.shiftwidth = 3

-- 4-space indent with spaces where the ecosystem expects it (PEP 8, Prettier, YAML)
vim.api.nvim_create_autocmd("FileType", {
    pattern = {"python", "yaml", "dockerfile"},
    callback = function() vim.bo.expandtab = true; vim.bo.shiftwidth = 4; vim.bo.tabstop = 4 end
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = {"javascript", "javascriptreact", "typescript", "typescriptreact", "json", "html", "css", "lua"},
    callback = function() vim.bo.expandtab = true; vim.bo.shiftwidth = 2; vim.bo.tabstop = 2 end
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = {"gitcommit", "markdown"},
    callback = function() vim.opt_local.spell = true end
})

-- filetype related 
vim.api.nvim_create_autocmd("FileType", {
    pattern = {"gitcommit"},
    callback = function(ev)
        vim.api.nvim_set_option_value("textwidth", 72, {scope = "local"})
    end
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = {"markdown"},
    callback = function(ev)
        vim.api.nvim_set_option_value("textwidth", 0, {scope = "local"})
        vim.api.nvim_set_option_value("wrapmargin", 0, {scope = "local"})
        vim.api.nvim_set_option_value("linebreak", true, {scope = "local"})
    end
})

-- Disable extra Python syntax highlighting
vim.api.nvim_create_autocmd("FileType", {
    pattern = {"python"},
    callback = function()
        vim.cmd([[
            syn clear pythonBuiltin
            syn clear pythonFunction
            syn clear pythonDecorator
        ]])
    end
})
