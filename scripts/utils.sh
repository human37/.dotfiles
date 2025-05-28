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
        echo $(redis-cli -c -p $PORT --scan)
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

    # Validate input
    if [ -z "$token" ]; then
        echo "Error: Please provide a JWT token"
        return 1
    fi

    # Check if jq is installed
    if ! command -v jq &>/dev/null; then
        echo "Error: jq is not installed. Please install it to decode JSON."
        return 1
    fi

    echo -n "$token" | awk -F"." '{print $2}' | base64 -d | jq
}


function td() {
  nvim ~/.todo/todo.md
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
