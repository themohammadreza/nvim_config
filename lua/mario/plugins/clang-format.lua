return {
    "rhysd/vim-clang-format",
    init = function()
        vim.cmd([[
" Enable auto-format on save for C/C++ files
autocmd FileType c,cpp,h,hpp ClangFormatAutoEnable
        ]])
    end
}

