-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.api.nvim_create_user_command("FormatFile", function()
  require("conform").format({
    timeout_ms = 500,
    lsp_fallback = true,
  })
end, {
  desc = "Format entire file",
})

vim.api.nvim_create_user_command("DiffFormat", function()
  local lines = vim.fn.system("git diff --unified=0"):gmatch("[^\n\r]+")
  local ranges = {}
  for line in lines do
    if line:find("^@@") then
      local line_nums = line:match("%+.- ")
      if line_nums:find(",") then
        local _, _, first, second = line_nums:find("(%d+),(%d+)")
        table.insert(ranges, {
          start = { tonumber(first), 0 },
          ["end"] = { tonumber(first) + tonumber(second), 0 },
        })
      else
        local first = tonumber(line_nums:match("%d+"))
        table.insert(ranges, {
          start = { first, 0 },
          ["end"] = { first + 1, 0 },
        })
      end
    end
  end
  local format = require("conform").format
  for _, range in pairs(ranges) do
    format({
      range = range,
    })
  end
end, { desc = "Format changed lines" })

-- Format on save for git changes only
vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("FormatOnSaveGit", {
        clear = true
    }),
    callback = function()
        -- Debug function that safely handles tables
        local function debug(msg, tbl)
            if tbl then
                vim.cmd(string.format('echom "%s: %s"', msg, vim.inspect(tbl):gsub('"', '\\"'):gsub('\n', ' ')))
            else
                vim.cmd(string.format('echom "%s"', tostring(msg):gsub('"', '\\"')))
            end
        end

        -- Get indentation level of a line
        local function get_indentation(line)
            return line:match("^%s*"):len()
        end

        -- Get content without indentation
        local function get_content(line)
            return line:gsub("^%s*", "")
        end

        -- Find the correct indentation for a line based on context
        local function find_context_indentation(lines, line_num)
            -- Look at previous non-empty lines
            for i = line_num - 1, 1, -1 do
                local line = lines[i]
                if line and line:match("%S") then -- Found non-empty line
                    local content = get_content(line)
                    -- If previous line has a block opener, increase indentation
                    if content:match("{%s*$") then
                        return get_indentation(line) + 2
                    end
                    -- If it's a similar type of line (e.g., field declaration), use same indentation
                    if content:match("^[%w@]") then
                        return get_indentation(line)
                    end
                end
            end
            return 2 -- Default indentation
        end

        -- Disable all other formatting
        local current_autoformat = vim.g.autoformat
        vim.g.autoformat = false
        vim.b.autoformat = false

        -- Get hunks before any formatting
        local hunks = require("gitsigns").get_hunks()
        if not hunks or #hunks == 0 then
            debug("No hunks found")
            vim.g.autoformat = current_autoformat
            return
        end

        debug("Number of hunks found", #hunks)

        -- Get original content
        local original_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        debug("Original line count", #original_lines)

        -- Track modified line ranges
        local ranges = {}
        for _, hunk in ipairs(hunks) do
            if hunk.type ~= "delete" then
                table.insert(ranges, {
                    start_line = hunk.added.start + 1, -- Convert to 1-based indexing
                    end_line = hunk.added.start + hunk.added.count
                })
                debug("Added range", {
                    start = hunk.added.start + 1,
                    count = hunk.added.count
                })
            end
        end

        -- Create a temporary buffer for formatting
        local temp_bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(temp_bufnr, 0, -1, false, original_lines)
        vim.api.nvim_buf_set_option(temp_bufnr, 'filetype', 'java')

        -- Format the temp buffer
        debug("Starting format")
        require("conform").format({
            bufnr = temp_bufnr,
            async = false,
            timeout_ms = 5000,
            formatters = {"google-java-format"}
        })

        -- Get formatted content
        local formatted_lines = vim.api.nvim_buf_get_lines(temp_bufnr, 0, -1, false)
        debug("Got formatted content", #formatted_lines)

        -- Create final content preserving unmodified lines
        local final_lines = {}
        for i = 1, #original_lines do
            local in_range = false
            for _, range in ipairs(ranges) do
                if i >= range.start_line and i <= range.end_line then
                    in_range = true
                    break
                end
            end

            if in_range then
                local orig_content = get_content(original_lines[i])
                if orig_content:match("%S") then -- Non-empty line
                    local context_indent = find_context_indentation(original_lines, i)
                    debug("Context indent for line", {
                        line = i,
                        indent = context_indent
                    })
                    final_lines[i] = string.rep(" ", context_indent) .. orig_content
                else
                    final_lines[i] = original_lines[i] -- Keep empty lines as-is
                end
            else
                final_lines[i] = original_lines[i]
            end
        end

        -- Clean up
        vim.api.nvim_buf_delete(temp_bufnr, {
            force = true
        })

        -- Verify changes
        local changes_made = 0
        for i = 1, #original_lines do
            if final_lines[i] ~= original_lines[i] then
                changes_made = changes_made + 1
                debug("Line changed", {
                    line_num = i,
                    original = original_lines[i],
                    new = final_lines[i]
                })
            end
        end
        debug("Total lines changed", changes_made)

        if changes_made > 0 then
            -- Apply changes
            vim.api.nvim_buf_set_lines(0, 0, -1, false, final_lines)
        else
            debug("No changes to apply")
        end

        vim.g.autoformat = current_autoformat
    end
})
