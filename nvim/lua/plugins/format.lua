return {{
    "stevearc/conform.nvim",
    opts = {
        formatters_by_ft = {
            java = {"google_java_format"}
        },
        -- LazyVim will handle format on save
        format = {
            timeout_ms = 500,
            async = false,
            quiet = true,
            lsp_fallback = true,
            filter = function(client)
                -- Check if we're in a git repository
                local is_git_repo = vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null"):find("true")
                if not is_git_repo then
                    -- Not a git repo, format the whole file
                    return true
                end

                -- Get hunks using gitsigns if available
                local ok, gitsigns = pcall(require, "gitsigns")
                if ok then
                    local hunks = gitsigns.get_hunks()
                    if not hunks or #hunks == 0 then
                        -- No changes, skip formatting
                        return false
                    end

                    -- Format only modified ranges
                    local ranges = {}
                    for _, hunk in ipairs(hunks) do
                        if hunk.type ~= "delete" then
                            local start_line = hunk.added.start
                            local count = hunk.added.count
                            -- Get the last line of the hunk
                            local last_line = vim.api.nvim_buf_get_lines(0, start_line + count - 2,
                                                  start_line + count - 1, true)[1]

                            table.insert(ranges, {
                                start = {start_line, 0},
                                ["end"] = {start_line + count - 1, #last_line}
                            })
                        end
                    end

                    -- Store ranges for formatting
                    vim.b.format_ranges = ranges
                    return true
                else
                    -- Fallback to git diff if gitsigns is not available
                    local has_changes = vim.fn.system("git diff --name-only " .. vim.fn.expand("%:p")) ~= ""
                    if not has_changes then
                        return false
                    end
                    return true
                end
            end
        }
    }
}}

