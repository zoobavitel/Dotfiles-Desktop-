return {
  {
    "bjarneo/aether.nvim",
    branch = "v2",
    name = "aether",
    priority = 1000,
    opts = {
      transparent = false,
      colors = {
        bg = "#050709",
        bg_dark = "#050709",
        bg_highlight = "#4a4a4a",
        fg = "#ffffff",
        fg_dark = "#993426",
        comment = "#4a4a4a",
        red = "#66a773",
        orange = "#a3cfa8",
        yellow = "#b4b47b",
        green = "#d24646",
        cyan = "#a360a3",
        blue = "#727272",
        purple = "#8686ba",
        magenta = "#afafd2",
      },
    },
    config = function(_, opts)
      require("aether").setup(opts)
      vim.cmd.colorscheme("aether")
      require("aether.hotreload").setup()
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "aether",
    },
  },
}
