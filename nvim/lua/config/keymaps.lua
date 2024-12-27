-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- -- Keymap Overrides for LazyVim

-- Override 's' key to substitute the character and remain in normal mode
vim.keymap.set("n", "s", "cl", { noremap = true, silent = true })
