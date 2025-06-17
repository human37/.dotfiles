# light mode
function mlight() {
    export SYSTEM_THEME="light"
    osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to false'

    # tmux light theme
    tmux set-environment SYSTEM_THEME "light"
    tmux source-file ~/.tmux.conf
}

# dark mode
function mdark() {
    export SYSTEM_THEME="dark"
    osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true'

    # tmux dark theme
    tmux set-environment SYSTEM_THEME "dark"
    tmux source-file ~/.tmux.conf
}
