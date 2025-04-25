return {
    {
        "LazyVim/LazyVim",
        opts = {
            format = {
                format_on_save = false,
                enabled = true
            }
        },
    },
    -- { -- Autoformat
    --   'stevearc/conform.nvim',
    --   event = { 'BufWritePre' },
    --   cmd = { 'ConformInfo' },
    --   config = function()
    --     -- Define the git changes formatting function at the top level
    --     local function format_git_changes()
    --       local hunks = require('gitsigns').get_hunks()
    --       if not hunks or #hunks == 0 then
    --         vim.notify('No git changes detected', vim.log.levels.INFO)
    --         return false
    --       end
          
    --       local format = require('conform').format
    --       for i = #hunks, 1, -1 do
    --         local hunk = hunks[i]
    --         if hunk ~= nil and hunk.type ~= 'delete' then
    --           local start = hunk.added.start
    --           local last = start + hunk.added.count
    --           -- nvim_buf_get_lines uses zero-based indexing -> subtract from last
    --           local last_hunk_line = vim.api.nvim_buf_get_lines(0, last - 2, last - 1, true)[1]
    --           local range = { start = { start, 0 }, ['end'] = { last - 1, last_hunk_line:len() } }
    --           format { range = range }
    --         end
    --       end
    --       vim.notify('Formatted ' .. #hunks .. ' changed regions', vim.log.levels.INFO)
    --       return true
    --     end
        
    --     -- Create the user command
    --     vim.api.nvim_create_user_command('FormatGitChanges', function()
    --       format_git_changes()
    --     end, {})
        
    --     -- Configure the formatter
    --     require('conform').setup({
    --       notify_on_error = false,
    --       format_on_save = function(bufnr)
    --         -- Try to format git changes first, fall back to normal formatting if none found
    --         if not format_git_changes() then
    --           return {
    --             timeout_ms = 500,
    --             lsp_format = 'fallback',
    --           }
    --         end
    --         return { timeout_ms = 500 }
    --       end,
    --       formatters_by_ft = {
    --         lua = { 'stylua' },
    --         java = { 'google-java-format' },
    --         go = { 'gofumpt', 'go-imports-reviser' },
    --       },
    --     })
    --   end,
    --   keys = {
    --     {
    --       '<leader>ff',
    --       function()
    --         require('conform').format { async = true, lsp_format = 'fallback' }
    --       end,
    --       mode = '',
    --       desc = '[F]ormat buffer',
    --     },
    --   },
    -- },
  }
