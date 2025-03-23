#!/bin/bash

# This script checks for new commits in the upstream repository and runs Docker Compose.
# Configuration can be overridden in ~/.deployr/.env.
# If CLIENT_ID, CLIENT_SECRET, and PROJECT_ID are set, it pulls secrets from Infisical for the same path structure as your project.

if [ -f ~/.deployr/.env ]; then
  source ~/.deployr/.env
else
  echo "Error: .env file not found"
  exit 1
fi

INFISICAL_API_URL="${INFISICAL_API_URL:-https://app.infisical.com}"
DOCKER_COMPOSE_PATH="${DOCKER_COMPOSE_PATH:-.}"
ROOT_SECRETS_FILENAME="${ROOT_SECRETS_FILENAME:-.env}"
SUBDIR_SECRETS_FILENAME="${SUBDIR_SECRETS_FILENAME:-.env}"
BASE_DIR="/root/deployr/$DOCKER_COMPOSE_PATH"

cd "$BASE_DIR" || exit 1

fetch_infisical_secrets() {

  if [[ -z "$CLIENT_ID" || -z "$CLIENT_SECRET" || -z "$PROJECT_ID" ]]; then
    echo "Skipping Infisical secret fetch: Missing CLIENT_ID, CLIENT_SECRET, or PROJECT_ID"
    return
  fi

  echo "Logging in to Infisical..."
  export INFISICAL_TOKEN=$(infisical login --method=universal-auth --client-id="$CLIENT_ID" --client-secret="$CLIENT_SECRET" --silent --plain --domain "$INFISICAL_API_URL")


  echo "Fetching root secrets..."
  infisical export --env=prod --projectId="$PROJECT_ID" --domain "$INFISICAL_API_URL" > "$ROOT_SECRETS_FILENAME"

  for dir in */; do
    if [ -d "$dir" ]; then
      echo "Processing directory: $dir"
      infisical export --env=prod --path="/$dir" --projectId="$PROJECT_ID" --domain "$INFISICAL_API_URL" > "$dir/$SUBDIR_SECRETS_FILENAME"

      if [ $? -eq 0 ]; then
        echo "Export successful for directory: $dir"
      else
        echo "Error: Export failed for directory: $dir"
      fi
    else
      echo "Skipping non-directory: $dir"
    fi
  done
}

update_and_apply_code() {
  git fetch

  if [ "$(git rev-list HEAD...origin/main --count)" -gt 0 ]; then
    echo "New commits found. Pulling changes..."
    git pull origin main
    docker compose -f "$BASE_DIR/docker-compose.yaml" up -d
  else
    echo "No new commits found."
  fi
}

fetch_infisical_secrets
update_and_apply_code

echo "Done"

