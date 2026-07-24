return {
  {
    "lewis6991/gitsigns.nvim",

    opts = {
      signs = {
        add          = { text = "│" },
        change       = { text = "│" },
        delete       = { text = "_" },
        topdelete    = { text = "‾" },
        changedelete = { text = "~" },
      },

      current_line_blame = false,
    },

    config = function(_, opts)
      require("gitsigns").setup(opts)

      local gs = require("gitsigns")
      local map = vim.keymap.set

      map("n", "]h", gs.next_hunk, { desc = "Next Hunk" })
      map("n", "[h", gs.prev_hunk, { desc = "Previous Hunk" })
      map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview Hunk" })
      map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset Hunk" })
      map("n", "<leader>hb", gs.toggle_current_line_blame, { desc = "Toggle Blame" })
    end,
  },
}
