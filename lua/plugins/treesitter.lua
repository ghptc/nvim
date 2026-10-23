return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",

		config = function()
			require("nvim-treesitter").setup()

			local parsers = {
				"lua",
				"vim",
				"vimdoc",
				"bash",
				"javascript",
				"typescript",
				"tsx",
				"html",
				"css",
				"json",
				"yaml",
				"sql",
				"dockerfile",
				"c_sharp",
				"c",
				"cpp",
				"markdown",
				"markdown_inline",
				"gitignore",
			}

			require("nvim-treesitter").install(parsers)

			vim.api.nvim_create_autocmd("FileType", {
				pattern = {
					"lua",
					"vim",
					"vimdoc",
					"bash",
					"javascript",
					"typescript",
					"typescriptreact",
					"html",
					"css",
					"json",
					"yaml",
					"sql",
					"dockerfile",
					"cs",
					"c",
					"cpp",
					"markdown",
					"gitignore",
				},
				callback = function()
					-- Parsers may still be installing on the first launch.
					pcall(vim.treesitter.start)
				end,
			})

		end,
	},
}
