return {
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",

    config = function()
      require("mason").setup({
        registries = {
          "github:mason-org/mason-registry",
          "github:Crashdummyy/mason-registry",
        },
      })
    end,
  },
}
