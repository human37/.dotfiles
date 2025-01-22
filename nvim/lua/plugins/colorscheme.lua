return {
  -- add tokyonight
  { "folke/tokyonight.nvim" },

  -- Configure LazyVim to load tokyonight
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-night",
    },
  },

  -- Configure tokyonight with transparent background
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        transparent = true,
        styles = {
          sidebars = "transparent",
          floats = "transparent",
        },
        on_highlights = function(hl)
          -- Additional highlight overrides if needed
          hl.Normal = { bg = "NONE" }
          hl.NormalFloat = { bg = "NONE" }
          hl.SignColumn = { bg = "NONE" }
          hl.TelescopeNormal = { bg = "NONE" }
          hl.NormalNC = { bg = "NONE" }
        end,
      })
      vim.cmd([[colorscheme tokyonight-night]])
    end,
  },
}
