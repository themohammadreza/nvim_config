

vim.keymap.set('n', '<leader>r', ':w<CR>:terminal cargo run<CR>')
vim.keymap.set('n', '<Tab>', ':bn<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<S-Tab>', ':bp<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<Esc>', '<Cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>w', '<Cmd>w<CR>')
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { silent = true })
vim.keymap.set('n', '<F5>', ':!g++ *.cpp -o main && ./main<CR>')
