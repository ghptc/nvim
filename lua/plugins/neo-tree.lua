return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		cmd = "Neotree",
		keys = {
			{
				"<leader>e",
				"<cmd>Neotree toggle<cr>",
				desc = "Toggle file tree",
			},
		},
		opts = {
			filesystem = {
				follow_current_file = {
					enabled = true,
				},
			},
			window = {
				position = "left",
				width = 32,
			},
		},
	},
}
