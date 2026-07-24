return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    branch = "master",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      ensure_installed = {
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
      },

      highlight = {
        enable = true,
      },

      indent = {
        enable = true,
      },
    },

    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
