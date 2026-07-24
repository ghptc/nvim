return {
	{
		"stevearc/oil.nvim",

		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},

		opts = {
			default_file_explorer = true,
			delete_to_trash = false,
			skip_confirm_for_simple_edits = true,
			view_options = {
				show_hidden = true,
			},
		},

		config = function(_, opts)
			require("oil").setup(opts)

			vim.keymap.set("n", "-", "<CMD>Oil<CR>", {
				desc = "Open parent directory",
			})
		end,
	},
}
