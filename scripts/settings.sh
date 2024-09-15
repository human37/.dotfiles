# light mode
function mlight() {
    osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to false'
}

# dark mode
function mdark() {
    osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true'
}
