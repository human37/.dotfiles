-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Remove empty line at bottom of neovim
vim.opt.cmdheight = 0  -- Command line height
vim.opt.laststatus = 3 -- Global statusline
vim.opt.fillchars = {
  eob = " ",  -- Suppress ~ at EndOfBuffer
  vert = "│", -- Continuous vertical split lines
}
