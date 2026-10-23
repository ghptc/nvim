return {
  {
    "Mofiqul/vscode.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.o.background = "dark"

      require("vscode").setup({
        style = "dark",
        transparent = false,
        terminal_colors = true,
        color_overrides = {
          vscBack = "#000000",
          vscPopupBack = "#000000",
          vscTabCurrent = "#000000",
          vscTabOther = "#000000",
          vscTabOutside = "#000000",
          vscLeftDark = "#000000",
        },
        group_overrides = {
          Normal = { bg = "#000000" },
          NormalNC = { bg = "#000000" },
          NormalFloat = { bg = "#000000" },
          FloatBorder = { bg = "#000000" },
          SignColumn = { bg = "#000000" },
          EndOfBuffer = { bg = "#000000" },
        },
      })

      vim.cmd.colorscheme("vscode")
    end,
  },
}
