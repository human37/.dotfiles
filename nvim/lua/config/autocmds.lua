-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.api.nvim_create_user_command('FormatFile', function()
    require('conform').format({
        timeout_ms = 500,
        lsp_fallback = true
    })
end, {
    desc = 'Format entire file'
})
