# save the current tmux state under a custom name
function tmux-s() {
  local name=$1
  local save_dir="$HOME/.local/share/tmux/resurrect"
  local save_file="$save_dir/last"

  if [[ -z "$name" ]]; then
    echo "❌ usage: tmux-s <name>"
    return 1
  fi

  echo "💾 saving tmux session as '$name'..."
  tmux run-shell ~/.tmux/plugins/tmux-resurrect/scripts/save.sh

  for i in {1..10}; do
    if [[ -f "$save_file" ]]; then
      break
    fi
    sleep 0.5
  done

  if [[ ! -f "$save_file" ]]; then
    echo "❌ failed to save session: file not found at $save_file"
    return 1
  fi

  cp "$save_file" "$save_dir/$name"
  echo "✅ saved as $save_dir/$name"
}

# Restore a previously saved tmux state by name
function tmux-r() {
  local name=$1
  local save_dir="$HOME/.local/share/tmux/resurrect"
  local save_path="$save_dir/$name"

  if [[ -z "$name" ]]; then
    echo "❌ usage: tmux-r <name>"
    return 1
  fi

  if [[ ! -f "$save_path" ]]; then
    echo "❌ no saved session found: $save_path"
    return 1
  fi

  echo "♻️ restoring tmux session from '$name'..."
  cp "$save_path" "$save_dir/last"
  tmux run-shell ~/.tmux/plugins/tmux-resurrect/scripts/restore.sh
  echo "✅ restored from $save_path"
}

# list all saved tmux sessions
function tmux-ls() {
   local save_dir="$HOME/.local/share/tmux/resurrect"

  if [[ ! -d "$save_dir" ]]; then
    echo "❌ resurrect save directory not found at $save_dir"
    return 1
  fi

  echo "📂 named tmux sessions:"
  ls "$save_dir" | \
    grep -vE '^last$' | \
    grep -vE '^tmux_resurrect_[0-9T]+\.txt$' | \
    sort

  if [[ $(ls "$save_dir" | grep -vE '^last$|^tmux_resurrect_[0-9T]+\.txt$' | wc -l) -eq 0 ]]; then
    echo "  (no named sessions found — use: tmux-save-session my-name)"
  fi
}
