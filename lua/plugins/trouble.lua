return {
	{
		"folke/trouble.nvim",

		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},

		opts = {},

		config = function(_, opts)
			require("trouble").setup(opts)

			local map = vim.keymap.set

			map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", {
				desc = "Diagnostics",
			})

			map("n", "<leader>xr", "<cmd>Trouble lsp_references toggle<cr>", {
				desc = "References",
			})

			map("n", "<leader>xs", "<cmd>Trouble symbols toggle<cr>", {
				desc = "Symbols",
			})

			map("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>", {
				desc = "Quickfix",
			})
		end,
	},
}
