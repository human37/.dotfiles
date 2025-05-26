# clean postgres data
function pgclean() {
  local localDir="${PWD}"
  cd /Users/ammon/zonos/DockerResources/postgres_cluster/
  docker compose down
  docker volume rm postgres_cluster_postgres_writer_data postgres_cluster_postgres_reader_data
  cd $localDir
}

# reset docker
function reset_docker() {
  echo "stopping all docker containers..."
  docker stop $(docker ps -aq) 2>/dev/null
  echo "removing all stopped containers..."
  docker rm $(docker ps -a -q) 2>/dev/null
  echo "removing all dangling images..."
  docker rmi $(docker images -f "dangling=true" -q) 2>/dev/null
  echo "removing all unused images, not just dangling ones..."
  docker image prune -a --force 2>/dev/null
  echo "removing all unused volumes..."
  docker volume prune --force 2>/dev/null
  echo "removing all unused networks..."
  docker network prune --force 2>/dev/null
  echo "docker storage cleaned."
  docker network create zonos
  echo "cleaning postgres data..."
  pgclean
}

# fast docker compose up
function fdocker() {
  local localDir="${PWD}"

  cd /Users/ammon/zonos/DockerResources
  for dir in "$@"; do
    if [[ -d "$dir" ]]; then
      echo "entering directory $dir"
      cd "$dir" || return # change to the directory or exit if it fails

      local containerName=$(basename "$dir")
      local runningContainer=$(docker ps -q -f name="$containerName")

      if [[ -n "$runningContainer" ]]; then
        echo "stopping running container $containerName..."
        docker stop "$runningContainer"
      fi

      docker compose up -d
      echo "started container $containerName"
      cd - || return # return to the previous directory
    else
      echo "directory $dir does not exist."
    fi
  done
  cd $localDir
}
