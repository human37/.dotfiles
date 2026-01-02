# Runs a gradle command while adding local.env vars
function grun() {
  # Start with an empty command string
  local command=""

  # Parse flags
  local target_graph=""
  local filtered_args=()
  for arg in "$@"; do
    case "$arg" in
      --local-graph)
        # Assumption: local graph runs at 4000 as used earlier; change if you meant 400
        target_graph="http://localhost:4000/graphql"
        ;;
      --dev-graph)
        target_graph="https://internal-graph.dgs.dev.zdops.net/graphql"
        ;;
     --prod-graph)
        target_graph="https://internal-graph.dgs.prod.zdops.net/graphql"
        ;;
      *)
        filtered_args+=("$arg")
        ;;
    esac
  done
  # Replace positional params with filtered args
  set -- "${filtered_args[@]}"

  # If a target graph was provided, update ${PWD}/local.env
  if [[ -n "$target_graph" ]]; then
    local env_file="${PWD}/local.env"
    if [[ -f "$env_file" ]]; then
      if grep -Eq '^[[:space:]]*(export[[:space:]]+)?FEDERATED_URL[[:space:]]*=' "$env_file"; then
        # Replace existing line (BSD sed inline edit on macOS)
        sed -E -i '' "s|^[[:space:]]*(export[[:space:]]+)?FEDERATED_URL[[:space:]]*=.*$|FEDERATED_URL=$target_graph|g" "$env_file"
      else
        printf "\nFEDERATED_URL=%s\n" "$target_graph" >> "$env_file"
      fi
    else
      printf "FEDERATED_URL=%s\n" "$target_graph" > "$env_file"
    fi
  fi

  # Ensure the last line is processed by appending a newline to the input
  if [[ -f "${PWD}/local.env" ]]; then
    while IFS= read -r line || [[ -n "$line" ]]; do
      # Trim leading/trailing whitespace
      line="${line#"${line%%[![:space:]]*}"}"
      line="${line%"${line##*[![:space:]]}"}"
      # Skip blank or comment lines
      [[ -z "$line" || "$line" == \#* ]] && continue
      # Strip leading 'export'
      [[ "$line" == export* ]] && line="${line#export }"
      # Split key/value at first '='
      local key="${line%%=*}"
      local value="${line#*=}"
      # Trim spaces around key
      key="${key#"${key%%[![:space:]]*}"}"
      key="${key%"${key##*[![:space:]]}"}"
      if [[ -n "$key" ]]; then
        command+=" $key='$value'"
      fi
    done < "${PWD}/local.env"
  fi

  # Append the actual command to be executed
  command+=" SPRING_OUTPUT_ANSI_ENABLED=ALWAYS ./gradlew \"$@\""

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
  done <"${PWD}/local.env"

  # Append the actual command to be executed
  command+=" SPRING_OUTPUT_ANSI_ENABLED=ALWAYS ./gradlew \"$@\" --debug-jvm"

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
