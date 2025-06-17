function os() {
  # Check if the required arguments are provided
  if [[ $# -ne 2 ]]; then
    echo "Usage: org-store <env> <org ID or store ID>"
    return 1
  fi

  local env="$1"
  local identifier="$2"
  local credentialToken=""
  local endpoint=""
  local query=""

  # Determine the endpoint URL based on the environment
  if [[ "$env" == "p" ]]; then
    endpoint="https://internal-graph.dgs.prod.zdops.net/graphql"
    credentialToken=$PROD_CREDENTIAL_TOKEN
  elif [[ "$env" == "d" ]]; then
    endpoint="https://internal-graph.dgs.dev.zdops.net/graphql"
    credentialToken=$DEV_CREDENTIAL_TOKEN
  else
    echo "Invalid environment. Use 'p' for prod or 'd' for dev."
    return 1
  fi

  # Check if the identifier is an organization ID (starts with 'organization_')
  if [[ "$identifier" == organization_* ]]; then
    # Construct the GraphQL query for an organization ID
    query=$(
      cat <<EOF
query Organizations {
    organizations(filter: { organizations: ["$identifier"] }, first: 10) {
        edges {
            cursor
            node {
                id
                businessUnit
                createdAt
                createdBy
                name
                parent
                status
                type
                updatedAt
                updatedBy
                references {
                    companyId
                    crmCustomerId
                    crmCustomerUrl
                    processorCustomerId
                    processorCustomerUrl
                    salesRepresentative
                    storeId
                }
            }
        }
    }
}
EOF
    )
  else
    # Assume the identifier is a store ID and construct the query
    query=$(
      cat <<EOF
query Organizations {
    organizations(filter: { storeId: $identifier }, first: 10) {
        edges {
            cursor
            node {
                id
                businessUnit
                createdAt
                createdBy
                name
                parent
                status
                type
                updatedAt
                updatedBy
                references {
                    companyId
                    crmCustomerId
                    crmCustomerUrl
                    processorCustomerId
                    processorCustomerUrl
                    salesRepresentative
                    storeId
                }
            }
        }
    }
}
EOF
    )
  fi

  # Encode the query to escape special characters
  local encoded_query=$(jq -Rs '.' <<<"$query")

  {
    response=$(curl -s -X POST \
      -H "Content-Type: application/json" \
      -H "credentialToken: $credentialToken" \
      -d '{"query":'"$encoded_query"'}' \
      "$endpoint")
    echo "$response" >/tmp/query_org_response.$$ # Save response to a temporary file
  } >/dev/null 2>&1 &
  pid=$!
  disown

  # Display loading indicator while curl is running
  echo -n "loading... "
  spin='-\|/'
  i=0
  while kill -0 $pid 2>/dev/null; do
    i=$(((i + 1) % 4))
    printf "\b${spin:$i:1}"
    sleep 0.1
  done
  echo -e "\b done."

  # Read the response from the temporary file
  response=$(cat /tmp/query_org_response.$$)
  rm /tmp/query_org_response.$$

  # Use jq to parse the response
  local num_edges=$(echo "$response" | jq '.data.organizations.edges | length')

  if [[ "$num_edges" -eq 0 ]]; then
    echo "Error: No results found."
    return 1
  elif [[ "$num_edges" -gt 1 ]]; then
    echo "Error: More than one result found."
    echo "Results:"
    echo "$response" | jq '.data.organizations.edges[].node'
    return 1
  else
    # Extract the first node and format it nicely
    echo "$response" | jq '.data.organizations.edges[0].node'

    # Copy the store ID to the clipboard if the identifier is an organization ID
    if [[ "$identifier" == organization_* ]]; then
      store_id=$(echo "$response" | jq -r '.data.organizations.edges[0].node.references.storeId')
      echo -n "$store_id" | pbcopy
    else
      org_id=$(echo "$response" | jq -r '.data.organizations.edges[0].node.id')
      echo -n "$org_id" | pbcopy
    fi
  fi
}

function vc() {
  # Check if the required arguments are provided
  if [[ $# -lt 2 ]]; then
    echo "Usage: vc <env> <credentialToken> [permissions_filter]"
    return 1
  fi

  local env="$1"
  local credentialToken="$2"
  local permissions_filter="$3"
  local endpoint=""
  local senderCredential=""

  # Determine the endpoint URL and sender credential based on the environment
  case "$env" in
  "prod")
    endpoint="https://dgs-auth.dgs.prod.zdops.net/graphql"
    senderCredential=$PROD_SENDER_CREDENTIAL
    ;;
  "dev")
    endpoint="https://dgs-auth.dgs.dev.zdops.net/graphql"
    senderCredential=$DEV_SENDER_CREDENTIAL
    ;;
  "ups-zonos")
    endpoint="https://dgs-auth.zonos.us-east-2.z-ups.net/graphql"
    senderCredential=$UPS_ZONOS_SENDER_CREDENTIAL
    ;;
  "ups-dev")
    endpoint="https://dgs-auth.dev.us-east-2.z-ups.net/graphql"
    senderCredential=$UPS_DEV_SENDER_CREDENTIAL
    ;;
  "ups-uat")
    endpoint="https://dgs-auth.uat.us-east-2.z-ups.net/graphql"
    senderCredential=$UPS_UAT_SENDER_CREDENTIAL
    ;;
  "ups-prod")
    endpoint="https://dgs-auth.prod.us-east-2.z-ups.net/graphql"
    senderCredential=$UPS_PROD_SENDER_CREDENTIAL
    ;;
  *)
    echo "Invalid environment. Use: prod, dev, ups-zonos, ups-dev, ups-uat, or ups-prod"
    return 1
    ;;
  esac

  # Construct the GraphQL mutation
  local mutation='mutation ValidateCredential {
        validateCredential {
            id
            createdAt
            validUntil
            credential
            organization
            serviceToken
            user
            store
            permissions
            mode
        }
    }'

  # Encode the mutation to escape special characters
  local encoded_mutation=$(jq -Rs '.' <<<"$mutation")

  # Send the request using curl
  response=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -H "credentialToken: $credentialToken" \
    -H "senderCredential: $senderCredential" \
    -d '{"query":'"$encoded_mutation"'}' \
    "$endpoint")

  # If permissions filter is provided, use it with jq
  if [[ -n "$permissions_filter" ]]; then
    echo "$response" | jq -C ".data.validateCredential | {permissions: .permissions | map(select(contains(\"$permissions_filter\"))), other: (. | del(.permissions))}" | less -R
  else
    echo "$response" | jq -C | less -R
  fi
}

function aws_login() {
  CODE=$1
  aws_login_script human37-iphone zdops $CODE
}

function aws_login_ups() {
  CODE=$1
  aws_login_script human37 zups $CODE
}

function aws_ssm() {
  SERVICE=$1
  ENV_STR=$2
  RAW_FLAG=$3
  if [ -z "$SERVICE" ]; then
    echo "missing args: aws_ssm <service> [env] [raw]"
    return
  fi
  if [[ "$SERVICE" == */* ]]; then
    SSM_PATH=$1
  else
    SSM_PATH=/$ENV_STR/apps/$SERVICE/secrets
  fi
  if [[ $SSM_PATH != */ ]]; then
    SSM_PATH=${SSM_PATH}/
  fi
  echo "Results for: $SSM_PATH"
  if [[ "$RAW_FLAG" == "raw" ]]; then
    aws --profile zdops-mfa --region us-east-2 ssm get-parameters-by-path --path "$SSM_PATH" --recursive --with-decryption --query "Parameters[*].{Name:Name,Value:Value}" | jq -r '.[] | .Name['${#SSM_PATH}':] + "=" + (.Value | gsub("\n"; "\\n"))' | sort | cat
  else
    aws --profile zdops-mfa --region us-east-2 ssm get-parameters-by-path --path "$SSM_PATH" --recursive --with-decryption --query "Parameters[*].{Name:Name,Value:Value}" | jq -r '.[] | .Name['${#SSM_PATH}':] + "=" + (.Value | gsub("\n"; "\\n"))' | sort | bat --language=ini --file-name="SSM Results"
  fi
}

function aws_ssm_ups() {
  SERVICE=$1
  ENV_STR=$2
  RAW_FLAG=$3

  if [ -z "$SERVICE" ]; then
    echo "missing args: aws_ssm <service> [env] [raw]"
    return
  fi
  if [[ "$SERVICE" == */* ]]; then
    SSM_PATH=$1
  else
    SSM_PATH=/$ENV_STR/apps/$SERVICE/secrets
  fi
  if [[ $SSM_PATH != */ ]]; then
    SSM_PATH=${SSM_PATH}/
  fi
  echo "Results for: $SSM_PATH"
  if [[ "$RAW_FLAG" == "raw" ]]; then
    aws --profile zups-mfa --region us-east-2 ssm get-parameters-by-path --path "$SSM_PATH" --recursive --with-decryption --query "Parameters[*].{Name:Name,Value:Value}" | jq -r '.[] | .Name['${#SSM_PATH}':] + "=" + (.Value | gsub("\n"; "\\n"))' | sort | cat
  else
    aws --profile zups-mfa --region us-east-2 ssm get-parameters-by-path --path "$SSM_PATH" --recursive --with-decryption --query "Parameters[*].{Name:Name,Value:Value}" | jq -r '.[] | .Name['${#SSM_PATH}':] + "=" + (.Value | gsub("\n"; "\\n"))' | sort | bat --language=ini --file-name="SSM Results"
  fi
}

function ups_pg_password() {
  ENV=$1
  if [ -z "$ENV" ]; then
    echo "missing args: ups_pg_password <env>"
    return
  fi
  SSM_PATH=/user/human37/secrets/dgs/$ENV/POSTGRES_PASSWORD
  echo "Results for: $SSM_PATH\n"
  aws --profile zups-mfa --region us-east-2 ssm get-parameter --name "$SSM_PATH" --with-decryption --query "Parameter.Value"
}

function pglocal() {
  echo "connecting to pg-local..."

  # run pgcli and connect to the database
  pgcli -h localhost -p 5432 -U zonos --auto-vertical-output -d $1
}

function pglocal_ro() {
  echo "connecting to pg-local reader..."

  # run pgcli and connect to the database
  pgcli -h localhost -p 5433 -U zonos --auto-vertical-output -d $1
}

function pgdev() {
  echo "connecting to pg-dev..."

  # Set the environment variable for PostgreSQL password
  export PGPASSWORD=$(security find-generic-password -l "PG_DEV_PASSWORD" -w)

  # Define the local port
  PORT=5433

  # Check if the SSH tunnel is already established
  if ! lsof -i TCP:$PORT | grep ssh >/dev/null; then
    echo "Establishing SSH tunnel on port $PORT..."
    ssh -f -N bastion-dev
    echo "SSH tunnel established."
  else
    echo "SSH tunnel already running on port $PORT."
  fi

  # Run pgcli and connect to the database
  pgcli -h localhost -p "$PORT" -U ammontaylor --auto-vertical-output --row-limit 500 -d "$1"

  # Note: Do not close the SSH tunnel; it will persist due to ControlPersist

  # Unset the password after use
  unset PGPASSWORD
}

function pgprod() {
  echo "connecting to pg-prod..."

  # Set the environment variable for PostgreSQL password
  export PGPASSWORD=$(security find-generic-password -l "PG_PROD_PASSWORD" -w)

  # Define the local port
  PORT=5434

  # Check if the SSH tunnel is already established
  if ! lsof -i TCP:$PORT | grep ssh >/dev/null; then
    echo "Establishing SSH tunnel on port $PORT..."
    ssh -f -N bastion-prod
    echo "SSH tunnel established."
  else
    echo "SSH tunnel already running on port $PORT."
  fi

  # Run pgcli and connect to the database
  pgcli -h localhost -p "$PORT" -U ammontaylor --auto-vertical-output --row-limit 500 -d "$1"

  # Note: Do not close the SSH tunnel; it will persist due to ControlPersist

  # Unset the password after use
  unset PGPASSWORD
}

function pgupszonos() {
  echo "connecting to pg-ups-zonos..."

  # Set the environment variable for PostgreSQL password
  export PGPASSWORD=$(security find-generic-password -l "PG_UPS_ZONOS_PASSWORD" -w)

  # Define the local port
  PORT=5435

  # Check if the SSH tunnel is already established
  if ! lsof -i TCP:$PORT | grep ssh >/dev/null; then
    echo "Establishing SSH tunnel on port $PORT..."
    ssh -f -N bastion-ups-zonos-ro
    echo "SSH tunnel established."
  else
    echo "SSH tunnel already running on port $PORT."
  fi

  # Run pgcli and connect to the database
  pgcli -h localhost -p "$PORT" -U ammontaylor --auto-vertical-output --row-limit 500 -d "$1"

  # Note: Do not close the SSH tunnel; it will persist due to ControlPersist

  # Unset the password after use
  unset PGPASSWORD
}

function pgupsdev() {
  echo "connecting to pg-ups-dev..."

  # Set the environment variable for PostgreSQL password
  export PGPASSWORD=$(security find-generic-password -l "PG_UPS_DEV_PASSWORD" -w)

  # Define the local port
  PORT=5436

  # Check if the SSH tunnel is already established
  if ! lsof -i TCP:$PORT | grep ssh >/dev/null; then
    echo "Establishing SSH tunnel on port $PORT..."
    ssh -f -N bastion-ups-dev-ro
    echo "SSH tunnel established."
  else
    echo "SSH tunnel already running on port $PORT."
  fi

  # Run pgcli and connect to the database
  pgcli -h localhost -p "$PORT" -U ammontaylor --auto-vertical-output --row-limit 500 -d "$1"

  # Note: Do not close the SSH tunnel; it will persist due to ControlPersist

  # Unset the password after use
  unset PGPASSWORD
}

function pgupsuat() {
  echo "connecting to pg-ups-uat..."

  # Set the environment variable for PostgreSQL password
  export PGPASSWORD=$(security find-generic-password -l "PG_UPS_UAT_PASSWORD" -w)

  # Define the local port
  PORT=5438

  # Check if the SSH tunnel is already established
  if ! lsof -i TCP:$PORT | grep ssh >/dev/null; then
    echo "Establishing SSH tunnel on port $PORT..."
    ssh -f -N bastion-ups-uat-ro
    echo "SSH tunnel established."
  else
    echo "SSH tunnel already running on port $PORT."
  fi

  # Run pgcli and connect to the database
  pgcli -h localhost -p "$PORT" -U ammontaylor --auto-vertical-output --row-limit 500 -d "$1"

  # Note: Do not close the SSH tunnel; it will persist due to ControlPersist

  # Unset the password after use
  unset PGPASSWORD
}

function pgupsprod() {
  echo "connecting to pg-ups-prod..."

  # Set the environment variable for PostgreSQL password
  export PGPASSWORD=$(security find-generic-password -l "PG_UPS_PROD_PASSWORD" -w)

  # Define the local port
  PORT=5437

  # Check if the SSH tunnel is already established
  if ! lsof -i TCP:$PORT | grep ssh >/dev/null; then
    echo "Establishing SSH tunnel on port $PORT..."
    ssh -f -N bastion-ups-prod-ro
    echo "SSH tunnel established."
  else
    echo "SSH tunnel already running on port $PORT."
  fi

  # Run pgcli and connect to the database
  pgcli -h localhost -p "$PORT" -U ammontaylor --auto-vertical-output --row-limit 500 -d "$1"

  # Note: Do not close the SSH tunnel; it will persist due to ControlPersist

  # Unset the password after use
  unset PGPASSWORD
}

function pgclose() {
  echo "closing all SSH tunnels..."

  # The SSH host alias used in your SSH config
  SSH_HOST="bastion-dev"

  # Use ssh control command to terminate the master connection
  ssh -O exit "$SSH_HOST" 2>/dev/null

  if [[ $? -eq 0 ]]; then
    echo "SSH tunnels to '$SSH_HOST' have been closed."
  else
    echo "No active SSH tunnels to '$SSH_HOST' found."
  fi

  # The SSH host alias used in your SSH config
  SSH_HOST="bastion-prod"

  # Use ssh control command to terminate the master connection
  ssh -O exit "$SSH_HOST" 2>/dev/null

  if [[ $? -eq 0 ]]; then
    echo "SSH tunnels to '$SSH_HOST' have been closed."
  else
    echo "No active SSH tunnels to '$SSH_HOST' found."
  fi
}

function mytest() {
  echo "connecting to mysql-test..."

  export PAGER="less -S"

  export MYCLI_HOST='db-test.zonos.com'
  export MYCLI_USER='ammontaylor'
  export MYSQL_PWD=$(security find-generic-password -l "MYSQL_TEST_PASSWORD" -w)
  export MYCLI_PORT=3306

  mycli -h db-test.zonos.com -P 3306 -u ammontaylor --ssl $2

  unset MYCLI_HOST MYCLI_USER MYCLI_PASSWORD MYCLI_PORT
  unset PAGER
}

function myprod() {
  echo "connecting to mysql-prod..."

  export PAGER="less -S"

  export MYCLI_HOST='db-ro-prod.zonos.com'
  export MYCLI_USER='ammontaylor'
  export MYSQL_PWD=$(security find-generic-password -l "MYSQL_PROD_PASSWORD" -w)
  export MYCLI_PORT=3306

  mycli -h db-ro-prod.zonos.com -P 3306 -u ammontaylor --ssl $2

  unset MYCLI_HOST MYCLI_USER MYCLI_PASSWORD MYCLI_PORT
  unset PAGER
}

function myclose() {
  echo "closing all mysql sessions..."

  # Find all processes with 'mycli' in the command line owned by the current user
  PIDS=$(pgrep -u "$USER" -f mycli)

  if [[ -z "$PIDS" ]]; then
    echo "No active mycli sessions found."
  else
    echo "Terminating the following mycli processes: $PIDS"

    # Terminate each mycli process gracefully
    for PID in $PIDS; do
      kill -SIGTERM "$PID"
      echo "Terminated mycli process with PID: $PID"
    done

    echo "All mycli sessions have been closed."
  fi
}

function init_vsjava() {
  mkdir -p .vscode

  cat >.vscode/settings.json <<'EOL'
{
  "java.compile.nullAnalysis.mode": "automatic",
  "gradle.javaDebug.cleanOutput": true,
  "sqltools.connections": [
    {
      "previewLimit": 50,
      "server": "localhost",
      "port": 5432,
      "driver": "PostgreSQL",
      "name": "local",
      "username": "zonos",
      "password": "zonos",
      "database": "auth_test"
    }
  ],
  "java.jdt.ls.vmargs": "-XX:+UseParallelGC -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -Dsun.zip.disableMemoryMapping=true -Xmx2G -Xms100m -Xlog:disable",
  "java.configuration.updateBuildConfiguration": "automatic",
  "java.debug.settings.onBuildFailureProceed": true,
  "redis-console.port": 6381,
  "boot-java.change-detection.on": true
}
EOL

  cat >.vscode/launch.json <<'EOL'
  {
  "configurations": [
    {
      "type": "java",
      "request": "attach",
      "name": "debug dgs service",
      "processId": "${command:PickJavaProcess}"
    },
    {
      "type": "java",
      "name": "run legacy service",
      "request": "launch",
      "mainClass": "com.zonos.authdgs.AuthdgsApplication",
      "args": [
        "server",
        "config.yml"
      ],
      "projectName": "${workspaceFolder}",
      "cwd": "${workspaceFolder}",
      "env": {
        "ENV_FILE": "${workspaceFolder}/local.env"
      },
      "envFile": "${workspaceFolder}/local.env"
    }
  ]
}
EOL
}

function pgdump() {
  # Check if the required arguments are provided
  if [[ $# -ne 2 ]]; then
    echo "Usage: pgdump <env> <database>"
    return 1
  fi

  local env="$1"
  local database="$2"
  local timestamp=$(date +"%Y%m%d_%H%M%S")
  local port=""
  local user=""
  local password_key=""

  # Determine port and credentials based on environment
  case "$env" in
  "local")
    port="5432"
    user="zonos"
    ;;
  "dev")
    port="5433"
    user="ammontaylor"
    password_key="PG_DEV_PASSWORD"
    ;;
  "prod")
    port="5434"
    user="ammontaylor"
    password_key="PG_PROD_PASSWORD"
    ;;
  "ups-zonos")
    port="5435"
    user="ammontaylor"
    password_key="PG_PROD_PASSWORD"
    ;;
  "ups-dev")
    port="5436"
    user="ammontaylor"
    password_key="PG_PROD_PASSWORD"
    ;;
  "ups-prod")
    port="5437"
    user="ammontaylor"
    password_key="PG_PROD_PASSWORD"
    ;;
  *)
    echo "Invalid environment. Use: local, dev, prod, ups-zonos, ups-dev, or ups-prod"
    return 1
    ;;
  esac

  # Create db-dump directory if it doesn't exist
  mkdir -p ~/Zonos/db-dump

  # Set output file name with timestamp
  local output_file="${HOME}/Zonos/db-dump/${env}-${database}-${timestamp}.dump"

  # Set PGPASSWORD if needed
  if [[ -n "$password_key" ]]; then
    export PGPASSWORD=$(security find-generic-password -l "$password_key" -w)
  fi

  # Execute pg_dump
  pg_dump -h localhost -p "$port" -U "$user" -d "$database" -F c \
    -f "$output_file" \
    --exclude-table-data="public.*_seq" \
    --exclude-table-data="public.landed_cost*" \
    --exclude-table-data="public.levy*" \
    -N backup -N analytics -n public \
    --verbose

  # Unset PGPASSWORD
  unset PGPASSWORD

  echo "Database dump completed: $output_file"
}

function pgrestore() {
  # Check if the required arguments are provided
  if [[ $# -ne 2 ]]; then
    echo "Usage: pgrestore <dump_file> <database>"
    return 1
  fi

  local dump_file="$1"
  local database="$2"

  # Verify dump file exists
  if [[ ! -f "$dump_file" ]]; then
    echo "Error: Dump file not found: $dump_file"
    return 1
  fi

  # Execute pg_restore
  pg_restore -h localhost -p 5432 -U zonos -d "$database" "$dump_file"

  echo "Database restore completed for $database"
}

function ups_update_image() {
  # Check if the required arguments are provided
  if [[ $# -lt 3 ]]; then
    echo "Usage: ups_update_image <service_name> <environment> <image_tag>"
    return 1
  fi

  local service="$1"
  local environment="$2"
  local image_tag="$3"
  
  # Validate environment
  if [[ ! "$environment" =~ ^(zonos|dev|uat|prod)$ ]]; then
    echo "Error: Invalid environment. Must be one of: zonos, dev, uat, prod"
    return 1
  fi

  # Check if the tfvars file exists
  local tfvars_file="services/${service}/env-${environment}.tfvars"
  
  if [[ ! -f "$tfvars_file" ]]; then
    echo "Error: File not found: $tfvars_file"
    return 1
  fi
  
  echo "Updating $tfvars_file with image tag: $image_tag"
  
  # Update the image tag in the tfvars file
  # This replaces any "ups-..." tag with the provided tag
  sed -i '' -E "s/ups-[a-z0-9]+\"/${image_tag}\"/g" "$tfvars_file"
  
  echo "Updated $tfvars_file successfully"
}
