if vim.g.vscode then
  -- VSCode Neovim Config
  vim.g.mapleader = " "  -- Sets leader key to <Space>
  vim.g.maplocalleader = " "  -- Also set local leader to <Space>

  -- Use system clipboard for y and p
  vim.opt.clipboard = "unnamedplus"  -- Use system clipboard
  vim.keymap.set('n', 'p', 'p', { desc = "Paste after cursor" })

  -- Tab navigation
  vim.keymap.set('n', '<S-h>', '<Cmd>Tabprevious<CR>')
  vim.keymap.set('n', '<S-l>', '<Cmd>Tabnext<CR>')

  -- Move to window using the <ctrl> hjkl keys
  vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = "Go to Left Window", remap = true })
  vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = "Go to Lower Window", remap = true })
  vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = "Go to Upper Window", remap = true })
  vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = "Go to Right Window", remap = true })

  -- Resize windows using the <ctrl> arrow keys
  vim.keymap.set('n', '<C-Up>', '<Cmd>resize +2<CR>', { desc = "Increase Window Height", remap = true })
  vim.keymap.set('n', '<C-Down>', '<Cmd>resize -2<CR>', { desc = "Decrease Window Height", remap = true })
  vim.keymap.set('n', '<C-Left>', '<Cmd>vertical resize -2<CR>', { desc = "Decrease Window Width", remap = true })
  vim.keymap.set('n', '<C-Right>', '<Cmd>vertical resize +2<CR>', { desc = "Increase Window Width", remap = true })

  -- Create split windows
  vim.keymap.set("n", "<Leader>k", "<Cmd>call VSCodeNotify('workbench.action.splitEditorUp')<CR>", { silent = true })
  vim.keymap.set("n", "<Leader>j", "<Cmd>call VSCodeNotify('workbench.action.splitEditorDown')<CR>", { silent = true })
  vim.keymap.set("n", "<Leader>h", "<Cmd>call VSCodeNotify('workbench.action.splitEditorLeft')<CR>", { silent = true })
  vim.keymap.set("n", "<Leader>l", "<Cmd>call VSCodeNotify('workbench.action.splitEditorRight')<CR>", { silent = true })

else
  -- bootstrap lazy.nvim, LazyVim and your plugins
  require("config.lazy")
end
