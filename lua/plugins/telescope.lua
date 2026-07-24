return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },

    config = function()
      local telescope = require("telescope")

      telescope.setup({})

      local builtin = require("telescope.builtin")
      local keymap = vim.keymap

      keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
      keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
      keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
      keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help Tags" })
      keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent Files" })
    end,
  },
}
