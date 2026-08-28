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
					"markdown",
					"gitignore",
				},
				callback = function()
					vim.treesitter.start()
				end,
			})

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
					"markdown",
					"gitignore",
				},
				callback = function()
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},
}
