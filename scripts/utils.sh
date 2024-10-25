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
