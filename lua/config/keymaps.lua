vim.g.mapleader = " "

local keymap = vim.keymap.set

keymap("n", "<leader>w", "<cmd>w<CR>")
keymap("n", "<leader>q", "<cmd>q<CR>")

keymap("n", "<Esc>", "<cmd>nohlsearch<CR>")

keymap("n", "<leader>h", "<C-w>h")
keymap("n", "<leader>j", "<C-w>j")
keymap("n", "<leader>k", "<C-w>k")
keymap("n", "<leader>l", "<C-w>l")
