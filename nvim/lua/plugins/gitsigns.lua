return {
    "lewis6991/gitsigns.nvim",
    opts = {
        -- Optional configuration
        signs = {
            add = {
                text = '│'
            },
            change = {
                text = '│'
            },
            delete = {
                text = '_'
            },
            topdelete = {
                text = '‾'
            },
            changedelete = {
                text = '~'
            },
            untracked = {
                text = '┆'
            }
        },
        -- Enable line number highlights for changed lines
        numhl = true,
        -- Update signs in the sign column as you type
        signcolumn = true
    }
}
