function aws_login() {
    PROFILE=$1
    TOKEN=$2
    # bail if no args are passed
    if [[ -z "$TOKEN" || -z "$PROFILE" ]]; then
      echo "missing args: aws_login <username> <mfa_code>"
      return
    fi
    data=$(aws --profile zdops sts get-session-token --duration-seconds 129600 --serial-number arn:aws:iam::127143654397:mfa/$PROFILE --token-code "$TOKEN")
    ak=$(echo "$data" | jq -r '.Credentials.AccessKeyId')
    sk=$(echo "$data" | jq -r '.Credentials.SecretAccessKey')
    st=$(echo "$data" | jq -r '.Credentials.SessionToken')
    aws configure set aws_access_key_id "$ak" --profile mfa
    aws configure set aws_secret_access_key "$sk" --profile mfa
    aws configure set aws_session_token "$st" --profile mfa
}

function aws_ssm () {
    SERVICE=$1
    ENV_STR=$2
    if [ -z "$SERVICE" ]
    then
            echo "missing args: aws_ssm <service> [env]"
            return
    fi
    if [[ "$SERVICE" == */* ]]
    then
            SSM_PATH=$1
    else
            SSM_PATH=/$ENV_STR/apps/$SERVICE/secrets
    fi
    if [[ $SSM_PATH != */ ]]
    then
            SSM_PATH=${SSM_PATH}/
    fi
    echo "Results for: $SSM_PATH"
    aws --profile mfa --region us-east-2 ssm get-parameters-by-path --path "$SSM_PATH" --recursive --with-decryption --query "Parameters[*].{Name:Name,Value:Value}" | jq -r '.[] | .Name['${#SSM_PATH}':] + "=" + (.Value | gsub("\n"; "\\n"))' | sort
}
