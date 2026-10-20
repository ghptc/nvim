vim.g.mapleader = " "

local keymap = vim.keymap.set

keymap("n", "<leader>w", "<cmd>w<CR>")
keymap("n", "<leader>q", "<cmd>q<CR>")

keymap("n", "<Esc>", "<cmd>nohlsearch<CR>")

keymap("n", "<leader>h", "<C-w>h")
keymap("n", "<leader>j", "<C-w>j")
keymap("n", "<leader>k", "<C-w>k")
keymap("n", "<leader>l", "<C-w>l")

keymap("n", "<leader>db", function() require("config.dotnet").task("build") end, { desc = "dotnet build" })
keymap("n", "<leader>dt", function() require("config.dotnet").task("test") end, { desc = "dotnet test" })
keymap("n", "<leader>cf", function() require("conform").format({ lsp_format = "fallback", timeout_ms = 3000 }) end,
    { desc = "Format buffer" })
