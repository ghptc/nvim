return {
	{
		"stevearc/conform.nvim",

		event = { "BufWritePre" },

		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				-- Roslyn owns C# formatting; no second formatter or process per save.
				cs = { lsp_format = "prefer" },

				javascript = { "prettier" },
				javascriptreact = { "prettier" },

				typescript = { "prettier" },
				typescriptreact = { "prettier" },

				json = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },

				sh = { "shfmt" },

				cpp = { "clang_format" },
				c = { "clang_format" },
			},

			format_on_save = {
				timeout_ms = 500,
				lsp_format = "fallback",
			},
		},
	},
}
