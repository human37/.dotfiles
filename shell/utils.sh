function unix_to_local() {
    local timestamp="$1"

    # Validate input: Check if the timestamp is a valid number
    if ! [[ "$timestamp" =~ ^[0-9]+$ ]]; then
        echo "Error: Invalid Unix timestamp. Please provide a numeric value."
        return 1
    fi

    # Optional: Check timestamp range (e.g., up to year 3000)
    if ((timestamp < 0 || timestamp > 32503680000)); then
        echo "Error: Unix timestamp out of valid range."
        return 1
    fi

    date -j -f %s $timestamp
}

function rkeys() {
    # Define the array of Redis cluster ports
    REDIS_CLUSTER_PORTS=(6379 6380 6381 6382 6383)

    # Check if redis-cli is installed
    if ! command -v redis-cli &>/dev/null; then
        echo "redis-cli could not be found. Please install it and try again."
        return 1
    fi

    # Iterate over each port in the array
    for PORT in "${REDIS_CLUSTER_PORTS[@]}"; do
        # Get all node addresses (IP:Port) for the current port
        KEYS=$(redis-cli -c -p $PORT --scan)
        # echo $KEYS
        if [ -n "$KEYS" ]; then
            echo "Keys on node $PORT:"
            echo "- - - -"
            for KEY in $KEYS; do
                VALUE=$(redis-cli -c -p "$PORT" GET "$KEY")
                echo "$KEY: $VALUE"
            done
            echo "- - - -"
        fi
    done
}

function kafka_listen() {
    local topic="$1"
    
    # Check if kcat is installed
    if ! command -v kcat &>/dev/null; then
        echo "Error: kcat could not be found. Please install it and try again."
        return 1
    fi
    
    # Format output with timestamps and pretty-print JSON if possible
    kcat -u -b localhost:9092 -t "$topic" -C \
        -f '\n- - - -\ntimestamp: %T partition: %p offset: %o\nvalue: %s\n- - - -\n' \
        | stdbuf -oL tr -d '\r' | while IFS= read -r line; do
            if [[ $line == "value:"* ]]; then
                # Extract the JSON part after "value: "
                json_part="${line#value: }"
                echo -n "message: "
                echo "$json_part" | jq --unbuffered '.'
            else
                echo "$line"
            fi
        done
}

function jwt() {
    local token="$1"

    if [ -z "$token" ]; then
        echo "Error: Please provide a JWT token"
        return 1
    fi

    if ! command -v jq &>/dev/null; then
        echo "Error: jq is not installed. Please install it to decode JSON."
        return 1
    fi

    echo -n "$token" | awk -F"." '{print $2}' | tr '_-' '/+' | awk '{len=length($0); if(len%4==2) print $0"=="; else if(len%4==3) print $0"="; else print $0}' | base64 -d | jq '
        # Convert common JWT timestamp fields to readable dates
        if .exp then .exp_readable = (.exp | strftime("%Y-%m-%d %H:%M:%S UTC")) else . end |
        if .iat then .iat_readable = (.iat | strftime("%Y-%m-%d %H:%M:%S UTC")) else . end |
        if .nbf then .nbf_readable = (.nbf | strftime("%Y-%m-%d %H:%M:%S UTC")) else . end
    '
}


function qtf() {
  /usr/bin/osascript <<'APPLESCRIPT'
  tell application "Ghostty" to activate

  -- Give macOS a heartbeat
  delay 0.05

  -- Click “Window → Fill”
  tell application "System Events"
    tell application process "Ghostty"
      if exists (menu item "Fill" of menu "Window" of menu bar 1) then
        click menu item "Fill" of menu "Window" of menu bar 1
      end if
    end tell
  end tell
APPLESCRIPT
}

function gce() {
  gh copilot explain "$@"
}

function killport() {
  if [ -z "$1" ]; then
    echo "Usage: killport <port>"
    return 1
  fi

  local pid
  pid=$(lsof -ti :$1)

  if [ -z "$pid" ]; then
    echo "No process found on port $1"
    return 0
  fi

  echo "Killing process $pid on port $1..."
  kill -9 $pid
}

function tda() {
  local name="$1"
  local cat="$2"
  gtodo add --task "$name" --cat "$cat"
}

function tdc() {
  local id="$1"
  local name="$2"
  gtodo update --id "$id" --task "$name" 
}

function runwf() {
  local workflows_dir="/Users/ammon/Zonos/workflows"
  local args=("$@")

  if [ ! -d "$workflows_dir" ]; then
    echo "Error: workflows directory not found at $workflows_dir"
    return 1
  fi

  local files=("$workflows_dir"/*-wf.py)
  if [ ${#files[@]} -eq 0 ]; then
    echo "Error: no workflow scripts found in $workflows_dir"
    return 1
  fi

  local selection
  if command -v fzf &>/dev/null; then
    selection=$(printf "%s\n" "${files[@]##*/}" | fzf --prompt="workflow> ")
  else
    echo "Select a workflow:"
    select selection in "${files[@]##*/}"; do
      break
    done
  fi

  if [ -z "$selection" ]; then
    echo "No workflow selected."
    return 1
  fi

  (cd "$workflows_dir" && "./$selection" "${args[@]}")
}
