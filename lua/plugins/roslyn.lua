return {
	{
		"seblyng/roslyn.nvim",
		ft = "cs",
		dependencies = { "neovim/nvim-lspconfig", "williamboman/mason.nvim" },
		opts = {},
		-- The plugin enables Roslyn while loading, before lazy calls config.
		init = function()
			vim.lsp.config("roslyn", {
				settings = {
					["csharp|background_analysis"] = {
						dotnet_analyzer_diagnostics_scope = "openFiles",
						dotnet_compiler_diagnostics_scope = "openFiles",
					},
				},
			})
		end,
		config = function(_, opts)
			require("roslyn").setup(opts)
			if vim.fn.executable(require("roslyn.utils").get_roslyn_lsp_path()) ~= 1 then
				vim.notify(
					"C# server missing. Run :MasonInstall roslyn, then reopen the C# buffer.",
					vim.log.levels.WARN
				)
			end
		end,
	},
}
