# Runs a gradle command while adding local.env vars
function grun() {
     # Start with an empty command string
    local command=""
    
    # Ensure the last line is processed by appending a newline to the input
    while IFS='=' read -r key value || [[ -n $key ]]; do
        # check if commented out
        if [[ $key == \#* ]]; then
            continue
        fi
        # Check if key is non-empty to avoid appending uninitialized variables
        if [[ -n $key ]]; then
            # Properly quote the value to handle spaces and special characters
            # Note: Adjusting the syntax to ensure correct handling of special characters
            command+=" $key='$value'"
        fi
    done < "${PWD}/local.env"
    
    # Append the actual command to be executed
    command+=" SPRING_OUTPUT_ANSI_ENABLED=ALWAYS ./gradlew $@"
    
    # Print the command to be executed (for debugging purposes)
    echo "executing command: $command"
    
    # Use eval to execute the constructed command
    eval "$command"
}

# Runs a gradle command while adding local.env vars in debug mode
function gdebug() {
     # Start with an empty command string
    local command=""
    
    # Ensure the last line is processed by appending a newline to the input
    while IFS='=' read -r key value || [[ -n $key ]]; do
        # check if commented out
        if [[ $key == \#* ]]; then
            continue
        fi
        # Check if key is non-empty to avoid appending uninitialized variables
        if [[ -n $key ]]; then
            # Properly quote the value to handle spaces and special characters
            # Note: Adjusting the syntax to ensure correct handling of special characters
            command+=" $key='$value'"
        fi
    done < "${PWD}/local.env"
    
    # Append the actual command to be executed
    command+=" SPRING_OUTPUT_ANSI_ENABLED=ALWAYS ./gradlew $@ --debug-jvm"
    
    # Print the command to be executed (for debugging purposes)
    echo "executing command: $command"
    
    # Use eval to execute the constructed command
    eval "$command"
}

function gkill() {
    # Check if local.env exists in the current directory
    if [[ -f "local.env" ]]; then
        # Attempt to read the PORT variable value from the file
        local port=$(grep '^PORT=' local.env | cut -d'=' -f2)

        # Check if we successfully extracted a port number
        if [[ -n "$port" ]]; then
            # Find the process using the port
            local pid=$(lsof -t -i:$port)

            # Check if any PID was found
            if [[ -n "$pid" ]]; then
                # Kill the process using the found PID
                kill $pid
                echo "Process on port $port with PID $pid killed."
            else
                echo "No process is currently using port $port."
            fi
        else
            echo "PORT variable not found in local.env."
        fi
    else
        echo "local.env file not found in the current directory."
    fi
}
